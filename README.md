# Pixel Motif Designer

A production-quality Flutter application for designing pixel motifs. Built with **Clean Architecture**, **Provider** state management, and performance-first UI patterns optimized for continuous tap and drag drawing.

---

## Approach & Architecture

The project is organized into strict layers so each concern has a single responsibility and can be tested, extended, and explained independently — a key requirement for production apps and technical assessments.

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
| `_PixelGridGestureLayer` | Nothing (`context.read`) | Never on state change |

Updating one pixel rebuilds **one cell**, not the entire 16×16 grid.

### 2. Provider-level duplicate guards

| Guard | Location | Prevents |
|-------|----------|----------|
| Stroke tracking | `handlePixelDrag` | Re-processing the same cell during one drag stroke |
| Pixel check | `drawPixel` / `erasePixel` | Matrix copy when color is already correct |
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
  → drawPixel / erasePixel (based on selected tool)
  → _commit(new CanvasState)
  → notifyListeners()
  → Only affected _PixelCellAt rebuilds via context.select
```

### Domain models (immutable)

- **`Pixel`** — row, column, ARGB color; `isFilled` derived from empty state
- **`CanvasState`** — grid dimensions, active color, selected tool, pixel matrix
- **`DrawingTool`** — `draw` | `erase` enum for compile-time safety

Immutable snapshots make **undo/redo** straightforward to add later (push/pop `CanvasState` history).

---

## Project Structure

```
lib/
├── app.dart                 # MaterialApp + theme wiring
├── main.dart                # Entry point (no business logic)
│
├── core/
│   ├── constants/           # Grid size, colors, padding
│   ├── theme/               # Material 3 light theme
│   └── utils/
│
├── models/                  # Pure Dart domain models
│   ├── pixel.dart
│   ├── canvas_state.dart
│   └── drawing_tool.dart
│
├── providers/               # ChangeNotifier state management
│   ├── canvas_provider.dart # Canvas state + draw/erase logic
│   └── app_providers.dart   # MultiProvider registration
│
├── screens/
│   └── home/                # AppBar + centered PixelGrid
│
├── widgets/
│   ├── pixel_cell.dart      # Pure presentation cell
│   └── pixel_grid.dart      # Grid + gesture layer + selective rebuilds
│
├── services/                # Export, permissions (planned)
└── exports/                 # Barrel exports
```

---

## Tech Stack

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `flutter_svg` | SVG motif import/export (planned) |
| `path_provider` | Local file paths (planned) |
| `gal` | Save images to gallery (planned) |
| `permission_handler` | Runtime permissions (planned) |
| `screenshot` | Widget snapshot export (planned) |
| `xml` | SVG/XML parsing (planned) |

---

## Getting Started

### Prerequisites

- Flutter SDK ^3.12.2
- Dart ^3.12.2

### Run the app

```bash
flutter pub get
flutter run
```

### Run tests

```bash
flutter test
```

---

## Current Features

- [x] Clean Architecture folder structure
- [x] Material 3 light theme
- [x] Immutable domain models (`Pixel`, `CanvasState`, `DrawingTool`)
- [x] `CanvasProvider` with draw, erase, and clear logic
- [x] 16×16 pixel grid rendered from provider state
- [x] Per-cell selective rebuilds (`context.select` / `Selector`)
- [x] Tap-to-draw
- [x] Real-time drag drawing with duplicate prevention

## Planned Features

- [ ] Color palette UI
- [ ] Draw / Eraser toolbar
- [ ] Export to PNG / SVG
- [ ] Undo / Redo
- [ ] Save / load motifs

---

## Design Principles

1. **Separation of concerns** — UI displays; providers decide; models describe.
2. **Immutability** — State changes produce new objects, never in-place mutation.
3. **Performance by default** — Guards and selective subscriptions at every layer.
4. **Interview-ready** — Every layer has a clear, explainable responsibility.

---

## Author

**Divya Warule**
