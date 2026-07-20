# Architecture — Pixel Motif Designer

This document describes how the application is structured, why each layer exists, and how data flows between components. It reflects the **current** codebase (not planned-only features).

---

## Table of Contents

1. [Design Goals](#design-goals)
2. [Layer Overview](#layer-overview)
3. [State Management](#state-management)
4. [Domain Models](#domain-models)
5. [Provider Responsibilities](#provider-responsibilities)
6. [Services Layer](#services-layer)
7. [UI Layer](#ui-layer)
8. [Theme System](#theme-system)
9. [Theme System](#theme-system)
10. [App Launch & Splash](#app-launch--splash)
11. [About Screen](#about-screen)
12. [Undo / Redo](#undo--redo)
13. [Drawing Pipeline](#drawing-pipeline)
14. [Export Pipeline](#export-pipeline)
15. [Templates](#templates)
16. [Project Structure](#project-structure)
17. [Testing Strategy](#testing-strategy)
18. [Extension Points](#extension-points)

---

## Design Goals

1. **Separation of concerns** — Widgets display; providers decide; services perform I/O; models hold data.
2. **Immutability** — `CanvasState` and `Pixel` are value objects; mutations produce new instances.
3. **Performance** — Fine-grained rebuilds during drag drawing on 16×16 and 32×32 grids.
4. **Interview clarity** — Each file has one explainable responsibility.
5. **Non-breaking enhancement** — Features (themes, undo, templates) added without changing export or pixel color logic.

---

## Layer Overview

```
                    ┌──────────────────┐
                    │   main.dart      │
                    │   bootstrap only │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │   app.dart       │
                    │ ThemeProvider    │
                    │ MaterialApp      │
                    │ home: Splash     │
                    └────────┬─────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
  ┌──────▼──────┐    ┌───────▼───────┐   ┌──────▼──────┐
  │ SplashScreen│    │ HomeScreen    │   │ Templates   │
  │ (launch)    │───►│ (editor)      │   │ Screen      │
  └─────────────┘    └───────┬───────┘   └─────────────┘
                             │
  ┌──────▼───────────────────▼──────────────────────────┐
  │ Widgets (presentation + selective Provider reads)   │
  └──────┬──────────────────────────────────────────────┘
         │
  ┌──────▼──────────────────────────────────────────────┐
  │ Providers (ChangeNotifier)                          │
  │ CanvasProvider · ThemeProvider · PaletteProvider    │
  │ MotifProvider                                       │
  └──────┬──────────────────────────────────────────────┘
         │
  ┌──────▼──────────────────────────────────────────────┐
  │ Services                                            │
  │ ExportService · TemplateService · ThemePreferences  │
  │ SvgGenerator · PlatformDownloadSaver                │
  └──────┬──────────────────────────────────────────────┘
         │
  ┌──────▼──────────────────────────────────────────────┐
  │ Models (pure Dart)                                  │
  │ Pixel · CanvasState · CanvasHistorySnapshot         │
  │ DrawingTool · PixelTemplate                         │
  └─────────────────────────────────────────────────────┘
```

**Dependency rule:** Upper layers depend on lower layers. Models never import Flutter or Provider.

---

## State Management

[Provider](https://pub.dev/packages/provider) registers all `ChangeNotifier` instances in `AppProviders`:

| Provider | Scope | Must NOT contain |
|----------|-------|------------------|
| `ThemeProvider` | App-wide appearance | Canvas / drawing logic |
| `CanvasProvider` | Grid, tools, undo | Theme / export I/O |
| `PaletteProvider` | Swatch slot + custom color | Pixel matrix |
| `MotifProvider` | Export in-flight state | Direct pixel mutation |

### Selective rebuild pattern

```dart
// Only rebuilds when canUndo changes — not on every pixel paint
final canUndo = context.select<CanvasProvider, bool>(
  (p) => p.canUndo,
);
```

`_ThemedMaterialApp` uses `context.select<ThemeProvider, ThemeMode>` so theme changes do not notify `CanvasProvider` listeners.

---

## Domain Models

### `Pixel`

- Fields: `row`, `column`, `color` (32-bit ARGB).
- `Pixel.empty` uses transparent color `0x00000000`.
- Immutable; no Flutter imports.

### `CanvasState`

- Aggregate: grid dimensions, `activeColor`, `selectedTool`, `pixels` matrix.
- Factory: `CanvasState.initial()`.
- Mutations: `copyWith()`, `withPixelAt(row, col, pixel)`.
- Equality supports duplicate detection in `_commit`.

### `CanvasHistorySnapshot`

- Stores `gridRows`, `gridColumns`, cloned `pixels` for undo/redo stacks.
- `applyTo(current)` restores pixels while preserving current tool and color.

### `DrawingTool`

- Enum: `draw` | `erase`.

### `PixelTemplate`

- Built-in template metadata + ASCII pattern for `TemplateService`.

---

## Provider Responsibilities

### `CanvasProvider` (core drawing state)

| API | Behavior |
|-----|----------|
| `drawPixel` / `erasePixel` | Cell mutation with duplicate guards |
| `handlePixelDrag` | Drag path; stroke-level undo batching |
| `clearCanvas` | Full clear; creates undo entry |
| `changeGridSize` | New empty grid; undo entry |
| `loadTemplate` | Bulk pixel replace; undo entry |
| `undo` / `redo` | Stack navigation |
| `canUndo` / `canRedo` | Toolbar enabled state |

Internal commit paths:

- `_commitDuringStroke` — live drag pixels, no history push
- `_commitWithHistory` — discrete ops; pushes undo, clears redo
- `_commit` — tool/color changes; no history

### `PaletteProvider`

- Tracks `selectedSlot` (preset index or custom slot `5`).
- Stores `customColor` ARGB for the rainbow swatch.
- Separated from canvas so palette UI does not coupling to grid repaints.

### `ThemeProvider`

- Owns `ThemeMode` (light / dark / system).
- `setThemeMode()` → notify + `ThemePreferences.saveThemeMode()`.
- Loaded in `main()` before `runApp` to avoid theme flash.

### `MotifProvider`

- Orchestrates `ExportService.exportPng()` / `exportSvg()`.
- Exposes `isExporting` for button disabled state.

---

## Services Layer

| Service | Role |
|---------|------|
| `ExportService` | PNG capture + gallery save; SVG file write |
| `SvgGenerator` | Builds SVG XML from pixel matrix |
| `SvgExportLayout` | Viewport width/height/viewBox math |
| `PlatformDownloadSaver` | Android MediaStore MethodChannel |
| `TemplateService` | 6 built-in templates; scale 16→32 |
| `ThemePreferences` | SharedPreferences read/write for theme |

Services are **stateless** (or static). They receive data from providers and return results — no `ChangeNotifier`.

---

## UI Layer

### Screens

- `SplashScreen` — Branded launch animation; navigates to home after ~2.4s.
- `HomeScreen` — Editor layout (palette, toolbar, grid, export).
- `TemplatesScreen` — Template gallery grid.

### Key widgets

| Widget | Pattern |
|--------|---------|
| `SplashScreen` | Theme-aware gradient, logo asset, fade to home |
| `PixelGrid` | `Selector` for dimensions; grid `Listener` for pointer |
| `_PixelCellAt` | `context.select` on single cell color |
| `ColorPalette` | Single `Row`; preset + custom swatch |
| `EditingToolbar` | Tool + undo/redo with selective `select` |
| `AppDrawer` | Navigation; brightness-aware styling |
| `AboutSheet` | App identity from `AppConstants`; drawer entry |
| `EditorPanel` | Shared Material 3 card wrapper |

**Rule:** Widgets call `context.read<CanvasProvider>()` for actions; `context.select` for display state.

---

## Theme System

### Files

```
core/theme/
├── app_colors.dart   # Semantic tokens (light + dark)
├── app_theme.dart    # ThemeData builders
└── theme.dart        # Barrel export
```

### Light mode

- Material Blue (`#1976D2`) app bar, buttons, accents.
- Soft blue drawer wash (`primaryContainer`).

### Dark mode

- Neutral slate scaffold/surface — **not** full blue chrome.
- App bar uses elevated slate (`darkAppBar`), not primary blue.
- Soft accent `#6EA8FE` on buttons, icons, progress only.

### Persistence flow

```
main() → ThemePreferences.loadThemeMode()
       → PixelMotifApp(initialThemeMode)
       → ThemeProvider
       → User picks mode in AppearanceSheet
       → ThemePreferences.saveThemeMode()
```

---

## App Launch & Splash

### Bootstrap flow

```
OS native splash (solid theme color, no logo)
  → main() preserves splash via FlutterNativeSplash.preserve()
  → ThemePreferences.loadThemeMode()
  → PixelMotifApp → MaterialApp(home: SplashScreen)
  → SplashScreen first frame → FlutterNativeSplash.remove()
  → SplashScreen animation (~2.4s)
  → pushReplacement → HomeScreen
```

### Native layer

`flutter_native_splash` generates Android/iOS **color-only** launch backgrounds (no logo image):

| Setting | Light | Dark |
|---------|-------|------|
| Background | `#E1E8F2` | `#0F1218` |
| Logo | None (animated splash only) | None |

Android also sets `NormalTheme` `windowBackground` to `@color/splash_background` so the window never flashes black while the Flutter engine starts.

Regenerate: `dart run flutter_native_splash:create`

### Flutter layer

`SplashScreen` (`lib/screens/splash/splash_screen.dart`):

- Calls `FlutterNativeSplash.remove()` after the first frame is painted.
- Reads active `ThemeData` for gradient and accent colors.
- Animates logo scale, text fade, and pixel grid background.
- Uses `Image.asset('assets/icon/app_icon.png')` — asset declared in `pubspec.yaml`.
- Tests pass `displayDuration: Duration.zero` or pump through the wait in `widget_test.dart`.

---

## About Screen

Drawer → **About** calls `showAboutSheet()`.

Content is sourced from `AppConstants` (single source of truth):

| Constant | Purpose |
|----------|---------|
| `appName` / `appVersion` | Header |
| `appDescription` | Summary paragraph |
| `appFeatures` | Bullet list of capabilities |
| `appAuthor` | Credit line |
| `appContactEmail` | Contact email |

No provider involvement — presentation-only bottom sheet.

---

## Undo / Redo

### Stacks

- `_undoStack` / `_redoStack` of `CanvasHistorySnapshot`.
- Maximum **30** entries; oldest discarded on overflow.

### When history is saved

| Action | History moment |
|--------|----------------|
| Tap / drag stroke | `endStroke()` — one entry for entire stroke |
| Clear canvas | Before clear |
| Template load | Before load |
| Grid resize | Before resize |

### When history is NOT saved

- Each pixel during drag (batched at stroke end).
- Tool or color change.
- Undo/redo operations themselves.

### Redo invalidation

Any new edit after undo calls `_redoStack.clear()` — standard editor semantics.

---

## Drawing Pipeline

```
PointerDown → beginStroke() [capture baseline snapshot]
PointerMove → handlePixelDrag → drawPixel/erasePixel → _commitDuringStroke
PointerUp   → endStroke() [push baseline to undo if modified]
                ↓
         notifyListeners()
                ↓
    Only changed _PixelCellAt widgets rebuild
```

Gesture layer uses integer cell coordinates from local offset ÷ cell size — no per-cell gesture detectors.

---

## Export Pipeline

```
ExportSection tap
  → MotifProvider.exportPng/svg(canvasState)
  → ExportService
       PNG: RepaintBoundary / rasterize → gal.save
       SVG: SvgGenerator + SvgExportLayout → PlatformDownloadSaver (Android)
  → ExportResult → SnackBar feedback
```

Export reads `CanvasProvider.state` snapshot — never mutates canvas.

---

## Templates

```
TemplatesScreen → user confirms
  → TemplateService.planFor(template, currentGridSize)
  → optional resize dialog
  → CanvasProvider.loadTemplate(pixels, gridSize)
       single _commitWithHistory
```

Templates preserve `activeColor` and `selectedTool`. Pixel colors come from template patterns, not theme.

---

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/constants/     # grid, colors, layout
├── core/theme/         # AppTheme, AppColors
├── models/             # Pixel, CanvasState, templates
├── providers/          # All ChangeNotifiers
├── screens/home/
├── screens/splash/     # Branded launch animation
├── screens/templates/
├── services/           # I/O and generators
├── widgets/            # Reusable UI (drawer, about, palette, grid)
└── exports/

assets/icon/app_icon.png   # Launcher icon + animated splash logo

test/                        # Unit & widget tests
docs/DEVELOPER_GUIDE.md      # API & flow reference
```

---

## Testing Strategy

- **Unit tests** for providers, services, SVG math (no widget tree).
- **Widget smoke test** for app launch (splash → home) with mock SharedPreferences.
- Undo tests verify stroke batching, redo clearing, and 30-step cap.

Run: `flutter test` · `flutter analyze`

---

## Extension Points

| Future feature | Where to add |
|----------------|--------------|
| Save/load projects | New `MotifStorageService` + provider method |
| SVG import | `ImportService` parsing into `List<List<Pixel>>` |
| More templates | `TemplateService.templates` list |
| Additional grid sizes | `GridConstants.supportedGridSizes` + tests |

Follow existing patterns: immutable model → provider commit → selective widget subscription.
