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
- [Architecture](#architecture)
- [Performance Strategy](#performance-strategy)
- [Drawing Flow](#drawing-flow)
- [CanvasProvider API](#canvasprovider-api)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Design Principles](#design-principles)
- [Roadmap](#roadmap)

---

## Features

| Feature | Status | Description |
|---------|--------|-------------|
| Configurable grid (8×8, 16×16, 32×32) | ✅ Done | Drawer menu with confirmation before resize |
| Tap-to-draw | ✅ Done | Single tap paints or erases one cell |
| Drag drawing | ✅ Done | Continuous paint/erase while finger moves |
| Color palette | ✅ Done | 5 swatches — Black, Red, Blue, Green, Yellow |
| Draw / Eraser / Clear | ✅ Done | Material 3 toolbar with tool selection |
| Live pixel counter | ✅ Done | Real-time filled/total count with progress bar |
| Export PNG | ✅ Done | Saves to device gallery via `gal` |
| Export SVG | ✅ Done | Saves to `Downloads/Pixel Motif Designer` on Android |
| Material 3 UI | ✅ Done | Card panels, consistent spacing, accessibility |
| Undo / Redo | 🔜 Planned | Immutable state snapshots ready for this |
| Save / Load | 🔜 Planned | Persist motifs to local storage |
| Dark theme | 🔜 Planned | Theme layer prepared for extension |

---

## Screenshots & Layout

The home screen uses a fixed, non-scrollable column layout optimized for one-handed mobile use. Grid size is configured from the **navigation drawer** (hamburger menu, top-left).

```
┌─────────────────────────────────┐
│ ☰  Pixel Motif Designer         │
├─────────────────────────────────┤
│  Color Palette  ● ● ● ● ●       │
├─────────────────────────────────┤
│  [ Draw ] [ Eraser ]  [ Clear ] │
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
│  Canvas settings                │
├─────────────────────────────────┤
│  Grid size                      │
│  ○  8 × 8   Compact · 64 px     │
│  ● 16 × 16  Standard · 256 px   │
│  ○ 32 × 32  Large · 1024 px     │
└─────────────────────────────────┘
```

| UI Component | Widget | Provider interaction |
|--------------|--------|--------------------|
| Grid size | `GridSizeSelector` (drawer) | `changeGridSize()` |
| Color palette | `ColorPalette` | `changeActiveColor()` |
| Draw / Eraser / Clear | `EditingToolbar` | `changeDrawingTool()` / `clearCanvas()` |
| Pixel counter | `PixelCounterCard` | `filledPixelCount` / `totalPixelCount` |
| Pixel grid | `PixelGrid` | `handlePixelDrag()` |
| Export | `ExportSection` | `MotifProvider.exportPng()` / `exportSvg()` |

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
flutter devices        # list connected phones/emulators
flutter run -d <device-id>
```

### Run tests

```bash
flutter test
```

### Analyze code

```bash
flutter analyze
```

---

## How to Use

1. **Open settings** — Tap the **☰ menu** (top-left) to open the drawer.
2. **Choose grid size** — Select **8×8**, **16×16** (default), or **32×32**. Confirm when prompted; the canvas clears but your color and tool are preserved.
3. **Pick a color** — Tap a swatch in the color palette. The active swatch shows a border and checkmark.
4. **Select Draw** — Tap **Draw** in the toolbar (selected by default).
5. **Paint** — Tap or drag across the grid to fill pixels with the active color.
6. **Erase** — Tap **Eraser**, then tap or drag to clear pixels.
7. **Clear all** — Tap **Clear** to reset the entire grid. Color and tool selection are unchanged.
8. **Track progress** — Watch the **Canvas Usage** bar above the grid (`filled / total`).
9. **Export** — Tap **Export PNG** (gallery) or **Export SVG** (Downloads folder on Android).

---

## Export

### PNG

- Renders the canvas at **16 px per cell** (matching on-screen proportions).
- Saves to the **device gallery** via the [`gal`](https://pub.dev/packages/gal) package.
- Requests gallery permission on first export if needed.

### SVG

- Generates a vector file where each filled pixel becomes a `<rect>`.
- Viewport dimensions are computed dynamically via `SvgExportLayout`:

  ```
  svgWidth  = gridColumns × exportCellPixelSize
  svgHeight = gridRows    × exportCellPixelSize
  viewBox   = 0 0 svgWidth svgHeight
  ```

- **Android:** Saved directly to `Downloads/Pixel Motif Designer/` via MediaStore (no share sheet).
- **iOS / desktop:** Saved to Documents or opened via the system share sheet.

### Where to find exported files

| Format | Location |
|--------|----------|
| PNG | Device **Gallery / Photos** app |
| SVG | **Files → Downloads → Pixel Motif Designer** (Android) |

---

## Architecture

The project is organized into strict layers so each concern has a single responsibility and can be tested, extended, and explained independently.

```
┌─────────────────────────────────────────────────────────┐
│  UI Layer (screens / widgets)                           │
│  Detects gestures · Displays state · No business logic  │
├─────────────────────────────────────────────────────────┤
│  State Layer (providers)                                │
│  CanvasProvider · MotifProvider · Tool routing          │
├─────────────────────────────────────────────────────────┤
│  Services Layer                                         │
│  ExportService · SvgGenerator · PlatformDownloadSaver   │
├─────────────────────────────────────────────────────────┤
│  Domain Layer (models)                                  │
│  Pixel · CanvasState · DrawingTool · Pure Dart          │
├─────────────────────────────────────────────────────────┤
│  Core (constants / theme / utils)                       │
│  Shared configuration and presentation tokens           │
└─────────────────────────────────────────────────────────┘
```

### Why Provider?

[Provider](https://pub.dev/packages/provider) was chosen because it:

- Integrates natively with Flutter's widget tree
- Supports **fine-grained rebuilds** via `context.select` and `Selector`
- Has a minimal learning curve — easy to explain in interviews
- Scales well for this app's scope without the boilerplate of heavier solutions

All canvas mutations flow through `CanvasProvider`. Export orchestration flows through `MotifProvider`. Widgets never modify pixel data directly.

---

## Performance Strategy

Continuous drag drawing is one of the most performance-sensitive features. The implementation uses **three layers of optimization**:

### 1. Fine-grained widget rebuilds

| Widget | Subscribes to | Rebuilds when |
|--------|---------------|---------------|
| `PixelGrid` | `(gridRows, gridColumns)` | Grid size changes |
| `_PixelCellAt` | `pixels[row][column].color` | **That cell's color changes** |
| `_ColorSwatch` | `activeColor == swatchColor` | Its selection state changes |
| `_ToolButton` | `selectedTool == tool` | Its selection state changes |
| `PixelCounterCard` | `(filledPixelCount, totalPixelCount)` | Count changes |
| `GridSizeSelector` | `gridRows` | Grid size changes |
| `_ClearCanvasButton` | Nothing (`context.read`) | Never on state change |
| `_PixelGridGestureLayer` | Nothing (`context.read`) | Never on state change |

Updating one pixel rebuilds **one cell**, not the entire grid.

### 2. Provider-level duplicate guards

| Guard | Location | Prevents |
|-------|----------|----------|
| Stroke tracking | `handlePixelDrag` | Re-processing the same cell during one drag stroke |
| Pixel check | `drawPixel` / `erasePixel` | Matrix copy when color is already correct |
| Incremental counter | `_filledPixelCount` | Full-matrix scan on every rebuild |
| Tool/color check | `changeDrawingTool` / `changeActiveColor` | Notification when value unchanged |
| Commit gate | `_commit` | `notifyListeners` when `CanvasState` is unchanged |

### 3. Paint isolation

Each cell is wrapped in a `RepaintBoundary` so Flutter does not repaint neighbouring cells when one pixel changes during rapid drawing.

---

## Drawing Flow

### Tap & drag input

A single grid-level `Listener` captures raw pointer events — no pan slop delay, immediate response on finger down and move.

```
Pointer down / move
  → _cellCoordinatesFromOffset(localPosition)
  → CanvasProvider.handlePixelDrag(row, column)
  → _applyToolAt → drawPixel / erasePixel (based on selectedTool)
  → _commit(new CanvasState)
  → notifyListeners()
  → Only affected _PixelCellAt rebuilds via context.select
```

### Grid resize

```
Select size in drawer → confirmation dialog
  → CanvasProvider.changeGridSize(size)
  → New empty CanvasState (preserves color + tool)
  → PixelGrid Selector rebuilds scaffold
  → PixelCounterCard updates total count
```

### Domain models (immutable)

- **`Pixel`** — row, column, ARGB color; `isFilled` derived from empty state
- **`CanvasState`** — grid dimensions, active color, selected tool, pixel matrix
- **`DrawingTool`** — `draw` | `erase` enum for compile-time safety

Immutable snapshots make **undo/redo** straightforward to add later (push/pop `CanvasState` history).

---

## CanvasProvider API

| Method / getter | Purpose |
|-----------------|---------|
| `changeActiveColor(int color)` | Set paint color (does not alter existing pixels) |
| `changeDrawingTool(DrawingTool tool)` | Switch between draw and eraser |
| `changeGridSize(int size)` | Resize canvas; clears pixels; keeps color & tool |
| `drawPixel(int row, int column)` | Paint active color at cell |
| `erasePixel(int row, int column)` | Clear cell to empty |
| `handlePixelTap(int row, int column)` | Apply active tool on tap |
| `handlePixelDrag(int row, int column)` | Apply active tool during drag |
| `beginStroke()` / `endStroke()` | Manage per-stroke duplicate tracking |
| `clearCanvas()` | Reset all pixels; preserves color and tool |
| `filledPixelCount` | O(1) running count of painted cells |
| `totalPixelCount` | `gridRows × gridColumns` |

---

## Project Structure

```
lib/
├── app.dart                    # MaterialApp + theme wiring
├── main.dart                   # Entry point (no business logic)
│
├── core/
│   ├── constants/              # Grid size, colors, padding, layout tokens
│   ├── theme/                  # Material 3 light theme
│   └── utils/
│
├── models/                     # Pure Dart domain models
│   ├── pixel.dart
│   ├── canvas_state.dart
│   └── drawing_tool.dart
│
├── providers/                  # ChangeNotifier state management
│   ├── canvas_provider.dart    # Canvas state + all drawing logic
│   ├── motif_provider.dart     # Export orchestration
│   └── app_providers.dart      # MultiProvider registration
│
├── screens/
│   └── home/                   # AppBar + drawer + editor layout
│
├── widgets/
│   ├── app_drawer.dart         # Navigation drawer shell
│   ├── grid_size_selector.dart # 8 / 16 / 32 grid picker
│   ├── color_palette.dart      # Selectable color swatches
│   ├── editing_toolbar.dart    # Draw, Eraser, Clear controls
│   ├── pixel_counter_card.dart # Live filled/total display
│   ├── editor_panel.dart       # Shared Material 3 card wrapper
│   ├── export_section.dart     # PNG + SVG export buttons
│   ├── pixel_cell.dart         # Pure presentation cell
│   └── pixel_grid.dart         # Grid + gesture layer + selective rebuilds
│
├── services/
│   ├── export_service.dart     # PNG gallery + SVG file save
│   ├── svg_generator.dart      # Canvas → SVG string
│   ├── svg_export_layout.dart  # Dynamic viewport sizing
│   └── platform_download_saver.dart  # Android MediaStore channel
│
└── exports/                    # Barrel exports

test/
├── widget_test.dart
└── svg_generator_test.dart       # SVG viewport + grid size tests
```

---

## Tech Stack

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `gal` | Save PNG images to device gallery |
| `share_plus` | SVG share fallback on iOS |
| `path_provider` | Local file paths for exports |
| `permission_handler` | Runtime gallery permissions |
| `xml` | SVG document generation |
| `flutter_svg` | SVG rendering support |
| `screenshot` | Widget snapshot utilities |

---

## Design Principles

1. **Separation of concerns** — UI displays; providers decide; models describe; services handle I/O.
2. **Immutability** — State changes produce new objects, never in-place mutation.
3. **Performance by default** — Guards and selective subscriptions at every layer.
4. **Reusable widgets** — Composable, provider-aware components with consistent Material 3 styling.
5. **Interview-ready** — Every layer has a clear, explainable responsibility.

---

## Roadmap

- [x] Export to PNG (gallery save)
- [x] Export to SVG (Downloads save on Android)
- [x] Custom grid sizes (8×8, 16×16, 32×32)
- [x] Live pixel counter
- [ ] Undo / Redo stack
- [ ] Save / load motif files
- [ ] Dark theme
- [ ] Motif import from SVG

---

## Author

**Divya Warule**
