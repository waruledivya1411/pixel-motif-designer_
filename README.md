# Pixel Motif Designer

A production-quality Flutter application for designing pixel motifs. Built with **Clean Architecture**, **Provider** state management, and performance-first UI patterns optimized for continuous tap and drag drawing.

**Repository:** [github.com/waruledivya1411/pixel-motif-designer_](https://github.com/waruledivya1411/pixel-motif-designer_)

---

## Table of Contents

- [Features](#features)
- [Screenshots & Layout](#screenshots--layout)
- [Getting Started](#getting-started)
- [How to Use](#how-to-use)
- [Export](#export)
- [Appearance & Themes](#appearance--themes)
- [Architecture](#architecture)
- [Documentation](#documentation)
- [Performance Strategy](#performance-strategy)
- [Tech Stack](#tech-stack)
- [Testing](#testing)
- [App Icon](#app-icon)
- [Roadmap](#roadmap)
- [Author](#author)

---

## Features

| Feature | Status | Description |
|---------|--------|-------------|
| Grid sizes (16×16, 32×32) | ✅ Done | Drawer selector with confirmation before resize |
| Tap-to-draw | ✅ Done | Single tap paints or erases one cell |
| Drag drawing | ✅ Done | Continuous paint/erase; one undo step per stroke |
| Color palette | ✅ Done | 5 presets + custom HSV picker on one row |
| Draw / Eraser / Clear | ✅ Done | Material 3 toolbar |
| Undo / Redo | ✅ Done | 30-step history; toolbar buttons with disabled states |
| Live pixel counter | ✅ Done | Filled/total count with visible progress bar |
| Pixel templates | ✅ Done | 6 built-in motifs; instant canvas load |
| Appearance (theme) | ✅ Done | Light, Dark, System — persisted via SharedPreferences |
| Export PNG | ✅ Done | Saves to device gallery via `gal` |
| Export SVG | ✅ Done | Saves to `Downloads/Pixel Motif Designer` (Android) |
| Material 3 UI | ✅ Done | Blue branding (light), slate surfaces (dark) |
| App launcher icon | ✅ Done | Generated from `assets/icon/app_icon.png` |
| Save / Load projects | 🔜 Planned | Persist motifs to local storage |
| SVG import | 🔜 Planned | Load external SVG motifs |

---

## Screenshots & Layout

The home screen uses a fixed, non-scrollable column layout optimized for one-handed mobile use. Settings live in the **navigation drawer** (☰, top-left).

```
┌─────────────────────────────────┐
│ ☰  Pixel Motif Designer         │  ← Blue app bar (light mode)
├─────────────────────────────────┤
│  ● ● ● ● ● ⊕   (color palette)  │  ← Presets + custom picker
├─────────────────────────────────┤
│ [Draw][Eraser][Clear][Undo][Redo]│
├─────────────────────────────────┤
│  Canvas Usage  ████░░  48/256   │
│  ┌───────────────────────────┐  │
│  │      Pixel Grid           │  │
│  └───────────────────────────┘  │
├─────────────────────────────────┤
│  [ Export PNG ] [ Export SVG ]  │
└─────────────────────────────────┘

Drawer (☰):
┌─────────────────────────────────┐
│  Pixel Motif Designer           │
├─────────────────────────────────┤
│  Home                           │
│  Templates                      │
│  Appearance    System Default    │
├─────────────────────────────────┤
│  Canvas settings                │
│  Grid size: 16×16 / 32×32       │
└─────────────────────────────────┘
```

| UI Component | Widget | Provider / Service |
|--------------|--------|-------------------|
| Grid size | `GridSizeSelector` | `CanvasProvider.changeGridSize()` |
| Color palette | `ColorPalette` | `PaletteProvider` + `CanvasProvider` |
| Tools + Undo/Redo | `EditingToolbar` | `CanvasProvider` |
| Pixel counter | `PixelCounterCard` | `filledPixelCount` / `totalPixelCount` |
| Pixel grid | `PixelGrid` | `handlePixelDrag()` |
| Export | `ExportSection` | `MotifProvider` → `ExportService` |
| Templates | `TemplatesScreen` | `TemplateService` + `loadTemplate()` |
| Appearance | `AppearanceSheet` | `ThemeProvider` + `ThemePreferences` |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.12.2`
- Dart `^3.12.2`
- Android Studio / Xcode (for device builds)

### Install & run

```bash
git clone https://github.com/waruledivya1411/pixel-motif-designer_.git
cd pixel-motif-designer_
flutter pub get
flutter run
```

### Run on a connected device

```bash
flutter devices
flutter run -d <device-id>
```

### Regenerate launcher icons (after changing logo)

```bash
dart run flutter_launcher_icons
```

### Run tests

```bash
flutter test
flutter analyze
```

---

## How to Use

1. **Open the drawer** — Tap **☰** (top-left).
2. **Choose grid size** — Under *Canvas settings*, pick **16×16** or **32×32**. Confirm when prompted.
3. **Pick a color** — Tap a preset swatch, or tap the **rainbow custom swatch** (after Yellow) to open the HSV picker.
4. **Draw** — Tap **Draw**, then tap or drag on the grid.
5. **Erase** — Tap **Eraser**, then tap or drag to clear pixels.
6. **Undo / Redo** — Use toolbar buttons; disabled when nothing is available.
7. **Clear** — Tap **Clear** to reset all pixels (undoable).
8. **Templates** — Drawer → **Templates** → pick a motif → **Load** (undoable).
9. **Appearance** — Drawer → **Appearance** → Light / Dark / System Default (saved automatically).
10. **Export** — **Export PNG** (gallery) or **Export SVG** (Downloads on Android).

---

## Export

### PNG

- Renders at **16 px per cell** (`GridConstants.exportCellPixelSize`).
- Saves to the **device gallery** via [`gal`](https://pub.dev/packages/gal).

### SVG

- Each filled pixel becomes a `<rect>`; viewport from `SvgExportLayout`.
- **Android:** `Downloads/Pixel Motif Designer/` via MediaStore.
- **iOS / desktop:** Documents or system share sheet.

| Format | Location |
|--------|----------|
| PNG | Gallery / Photos |
| SVG | Files → Downloads → Pixel Motif Designer (Android) |

---

## Appearance & Themes

| Mode | Behavior |
|------|----------|
| **Light** | Material Blue app bar, buttons, and drawer accents |
| **Dark** | Neutral slate surfaces; soft blue accent only on actions |
| **System Default** | Follows device setting; choice persisted on launch |

Implementation: `ThemeProvider` → `ThemePreferences` (SharedPreferences). See [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Architecture

The app follows strict layering: **UI → Providers → Services → Models → Core**.

```
┌─────────────────────────────────────────────────────────┐
│  UI (screens / widgets) — gestures & display only       │
├─────────────────────────────────────────────────────────┤
│  Providers — CanvasProvider, ThemeProvider, etc.        │
├─────────────────────────────────────────────────────────┤
│  Services — export, templates, theme persistence        │
├─────────────────────────────────────────────────────────┤
│  Models — Pixel, CanvasState, PixelTemplate (pure Dart) │
├─────────────────────────────────────────────────────────┤
│  Core — constants, Material 3 theme tokens              │
└─────────────────────────────────────────────────────────┘
```

**Full details:** [ARCHITECTURE.md](ARCHITECTURE.md)  
**Feature flows & APIs:** [docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md)

---

## Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Overview, setup, user guide |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Layers, providers, data flow, design decisions |
| [docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md) | APIs, undo/redo, themes, templates, testing |

---

## Performance Strategy

| Technique | Where | Benefit |
|-----------|-------|---------|
| `context.select` | Cells, toolbar, counter | Rebuild only affected widgets |
| `RepaintBoundary` | Each `PixelCell` | Isolate paint during drag |
| Grid-level `Listener` | `PixelGrid` | No pan slop; smooth drag |
| O(1) pixel counter | `CanvasProvider` | No full-matrix scan per frame |
| Stroke batching | Undo history | One history entry per drag stroke |
| Duplicate guards | `drawPixel`, `_commit` | Skip no-op state updates |

---

## Tech Stack

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `shared_preferences` | Theme mode persistence |
| `gal` | PNG → gallery |
| `share_plus` | SVG share fallback (iOS) |
| `path_provider` | Export file paths |
| `permission_handler` | Gallery permissions |
| `xml` | SVG generation |
| `flutter_launcher_icons` | App icon generation (dev) |

---

## Testing

```bash
flutter test
```

| Test file | Covers |
|-----------|--------|
| `canvas_provider_undo_test.dart` | Undo/redo, stroke batching, 30-step cap |
| `palette_provider_test.dart` | Custom color slot selection |
| `theme_preferences_test.dart` | Theme persistence |
| `template_service_test.dart` | Template scaling & loading |
| `svg_generator_test.dart` | SVG viewport & rects |
| `widget_test.dart` | App smoke test |

---

## App Icon

Source: `assets/icon/app_icon.png` (from `APP_LOGO.png`).

Adaptive Android icon uses dark background `#1A1A1F` with **8% inset** so the artwork stays inside OS mask shapes.

Regenerate after logo changes:

```bash
dart run flutter_launcher_icons
```

Then **reinstall** the app to see the new icon on the home screen.

---

## Roadmap

- [x] PNG & SVG export
- [x] Grid sizes 16×16 and 32×32
- [x] Live pixel counter
- [x] Pixel templates gallery
- [x] Undo / Redo (30 steps)
- [x] Custom color picker (HSV)
- [x] Light / Dark / System themes
- [x] Branded app launcher icon
- [ ] Save / load motif projects
- [ ] Import motifs from SVG

---

## Author

**Divya Warule**
