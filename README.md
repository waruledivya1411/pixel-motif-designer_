# Pixel Motif Designer

A production-quality Flutter application for designing pixel motifs. Built with **Clean Architecture**, **Provider** state management, and performance-first UI patterns optimized for continuous tap and drag drawing.

**Repository:** [github.com/waruledivya1411/pixel-motif-designer_](https://github.com/waruledivya1411/pixel-motif-designer_)

---

## Table of Contents

- [Features](#features)
- [Screenshots & Layout](#screenshots--layout)
- [Getting Started](#getting-started)
- [How to Use](#how-to-use)
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
| 16×16 pixel grid | ✅ Done | Dynamic grid driven by `CanvasProvider` / `GridConstants` |
| Tap-to-draw | ✅ Done | Single tap paints or erases one cell |
| Drag drawing | ✅ Done | Continuous paint/erase while finger moves |
| Color palette | ✅ Done | 5 swatches — Black, Red, Blue, Green, Yellow |
| Draw tool | ✅ Done | Paints with the active color |
| Eraser tool | ✅ Done | Clears pixels on tap or drag |
| Clear canvas | ✅ Done | Resets all pixels; keeps color & tool selection |
| Export PNG/SVG | 🔜 Planned | Gallery save and file export |
| Undo / Redo | 🔜 Planned | Immutable state snapshots ready for this |
| Save / Load | 🔜 Planned | Persist motifs to local storage |

---

## Screenshots & Layout

The home screen follows a top-to-bottom editing flow optimized for one-handed mobile use:

```
┌─────────────────────────────────┐
│  AppBar — Pixel Motif Designer  │
├─────────────────────────────────┤
│  Color Palette  ● ● ● ● ●       │
├─────────────────────────────────┤
│  [ Draw ] [ Eraser ]  [ Clear ] │
├─────────────────────────────────┤
│                                 │
│         16 × 16 Pixel Grid      │
│                                 │
└─────────────────────────────────┘
```

| UI Component | Widget | Provider interaction |
|--------------|--------|--------------------|
| Color Palette | `ColorPalette` | `changeActiveColor()` |
| Draw / Eraser | `EditingToolbar` | `changeDrawingTool()` |
| Clear | `EditingToolbar` | `clearCanvas()` |
| Pixel Grid | `PixelGrid` | `handlePixelDrag()` |

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

1. **Pick a color** — Tap a swatch in the color palette. The active color is highlighted with a border and checkmark.
2. **Select Draw** — Tap the **Draw** button in the toolbar (selected by default).
3. **Paint** — Tap or drag across the grid to fill pixels with the active color.
4. **Erase** — Tap **Eraser**, then tap or drag to clear pixels.
5. **Clear all** — Tap **Clear** to reset the entire grid. Your selected color and tool remain unchanged.

---

## Architecture

The project is organized into strict layers so each concern has a single responsibility and can be tested, extended, and explained independently.

```
┌─────────────────────────────────────────────────────────┐
│  UI Layer (screens / widgets)                           │
│  Detects gestures · Displays state · No business logic  │
├─────────────────────────────────────────────────────────┤
│  State Layer (providers)                                │
│  CanvasProvider · Tool routing · Duplicate guards       │
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

All canvas mutations flow through a single `CanvasProvider`. Widgets never modify pixel data directly.

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
| `_ClearCanvasButton` | Nothing (`context.read`) | Never on state change |
| `_PixelGridGestureLayer` | Nothing (`context.read`) | Never on state change |

Updating one pixel rebuilds **one cell**, not the entire 16×16 grid.

### 2. Provider-level duplicate guards

| Guard | Location | Prevents |
|-------|----------|----------|
| Stroke tracking | `handlePixelDrag` | Re-processing the same cell during one drag stroke |
| Pixel check | `drawPixel` / `erasePixel` | Matrix copy when color is already correct |
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

### Tool switching

```
Tap Draw or Eraser
  → changeDrawingTool(DrawingTool.draw | .erase)
  → _commit → notifyListeners()
  → Only the two _ToolButton widgets rebuild
```

### Domain models (immutable)

- **`Pixel`** — row, column, ARGB color; `isFilled` derived from empty state
- **`CanvasState`** — grid dimensions, active color, selected tool, pixel matrix
- **`DrawingTool`** — `draw` | `erase` enum for compile-time safety

Immutable snapshots make **undo/redo** straightforward to add later (push/pop `CanvasState` history).

---

## CanvasProvider API

| Method | Purpose |
|--------|---------|
| `changeActiveColor(int color)` | Set paint color (does not alter existing pixels) |
| `changeDrawingTool(DrawingTool tool)` | Switch between draw and eraser |
| `drawPixel(int row, int column)` | Paint active color at cell |
| `erasePixel(int row, int column)` | Clear cell to empty |
| `handlePixelTap(int row, int column)` | Apply active tool on tap |
| `handlePixelDrag(int row, int column)` | Apply active tool during drag |
| `beginStroke()` / `endStroke()` | Manage per-stroke duplicate tracking |
| `clearCanvas()` | Reset all pixels; preserves color and tool |

---

## Project Structure

```
lib/
├── app.dart                    # MaterialApp + theme wiring
├── main.dart                   # Entry point (no business logic)
│
├── core/
│   ├── constants/              # Grid size, colors, padding
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
│   └── app_providers.dart      # MultiProvider registration
│
├── screens/
│   └── home/                   # AppBar + Palette + Toolbar + Grid
│
├── widgets/
│   ├── color_palette.dart      # Selectable color swatches
│   ├── editing_toolbar.dart    # Draw, Eraser, Clear controls
│   ├── pixel_cell.dart         # Pure presentation cell
│   └── pixel_grid.dart         # Grid + gesture layer + selective rebuilds
│
├── services/                   # Export, permissions (planned)
└── exports/                    # Barrel exports
```

---

## Tech Stack

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `flutter_svg` | SVG motif import/export (planned) |
| `path_provider` | Local file paths (planned) |
| `gal` | Save images to device gallery (planned) |
| `permission_handler` | Runtime permissions (planned) |
| `screenshot` | Widget snapshot export (planned) |
| `xml` | SVG/XML parsing (planned) |

---

## Design Principles

1. **Separation of concerns** — UI displays; providers decide; models describe.
2. **Immutability** — State changes produce new objects, never in-place mutation.
3. **Performance by default** — Guards and selective subscriptions at every layer.
4. **Reusable widgets** — `PixelCell`, `ColorPalette`, `EditingToolbar` are composable and provider-aware where needed.
5. **Interview-ready** — Every layer has a clear, explainable responsibility.

---

## Roadmap

- [ ] Export to PNG (screenshot + gallery save)
- [ ] Export to SVG (xml generation)
- [ ] Undo / Redo stack
- [ ] Save / load motif files
- [ ] Custom grid sizes
- [ ] Dark theme

---

## Author

**Divya Warule**
