# Developer Guide — Pixel Motif Designer

Quick reference for engineers reviewing or extending this project. Pairs with [README.md](../README.md) and [ARCHITECTURE.md](../ARCHITECTURE.md).

---

## Feature Checklist (Implementation Status)

Use this to verify all requested capabilities are present in the codebase.

### Drawing & Canvas

| Requirement | Implemented | Location |
|-------------|-------------|----------|
| Single-tap draw | ✅ | `PixelGrid` → `handlePixelDrag` on pointer down |
| Drag drawing | ✅ | `PixelGrid` `_PixelGridGestureLayer` |
| Eraser | ✅ | `DrawingTool.erase` in `CanvasProvider` |
| Clear canvas | ✅ | `clearCanvas()` |
| 16×16 grid | ✅ | `GridConstants.defaultGridSize` |
| 32×32 grid | ✅ | `GridConstants.supportedGridSizes` |
| Grid change confirmation | ✅ | `GridSizeSelector._confirmGridSizeChange` |
| Live pixel counter | ✅ | `PixelCounterCard` + O(1) `_filledPixelCount` |

### Colors

| Requirement | Implemented | Location |
|-------------|-------------|----------|
| Preset swatches (5) | ✅ | `ColorConstants.drawingPalette` |
| Custom color picker | ✅ | `_CustomColorSwatch` + `CustomColorPickerSheet` |
| Single-row palette | ✅ | `ColorPalette` Row + 36px swatches |
| Pixel colors unchanged by theme | ✅ | `ColorConstants` separate from `AppTheme` |

### History

| Requirement | Implemented | Location |
|-------------|-------------|----------|
| Undo | ✅ | `CanvasProvider.undo()` |
| Redo | ✅ | `CanvasProvider.redo()` |
| Max 30 steps | ✅ | `CanvasProvider.maxHistorySize` |
| One undo per drag stroke | ✅ | `beginStroke` / `endStroke` baseline |
| Redo cleared on new edit | ✅ | `_commitWithHistory`, `endStroke` |
| Undo after clear/template/resize | ✅ | `canvas_provider_undo_test.dart` |

### Export

| Requirement | Implemented | Location |
|-------------|-------------|----------|
| PNG to gallery | ✅ | `ExportService` + `gal` |
| SVG to Downloads (Android) | ✅ | `PlatformDownloadSaver` + MediaStore |
| Dynamic SVG viewport | ✅ | `SvgExportLayout` |

### Templates

| Requirement | Implemented | Location |
|-------------|-------------|----------|
| Template gallery screen | ✅ | `TemplatesScreen` |
| 6 built-in templates | ✅ | `TemplateService` |
| Load with confirmation | ✅ | `_handleTemplateTap` |
| Auto-resize dialog | ✅ | When template > current grid |
| Undo template load | ✅ | `_commitWithHistory` in `loadTemplate` |

### Appearance

| Requirement | Implemented | Location |
|-------------|-------------|----------|
| Light mode | ✅ | `AppTheme.light` |
| Dark mode | ✅ | `AppTheme.dark` (slate, not day-blue) |
| System default | ✅ | `ThemeMode.system` |
| Drawer Appearance item | ✅ | `_AppearanceDrawerTile` |
| Persist across restarts | ✅ | `ThemePreferences` + SharedPreferences |
| Default = system on first launch | ✅ | `loadThemeMode()` returns system if unset |
| No AppBar theme toggle | ✅ | Theme only in drawer |

### Branding & UI

| Requirement | Implemented | Location |
|-------------|-------------|----------|
| Material 3 | ✅ | `useMaterial3: true` |
| Blue light theme | ✅ | `AppColors.primary` |
| Comfortable dark theme | ✅ | Slate surfaces in `app_colors.dart` |
| App launcher icon | ✅ | `flutter_launcher_icons` + `assets/icon/app_icon.png` |
| Drawer: Home, Templates, Appearance | ✅ | `AppDrawer` |
| Card contrast (panels vs background) | ✅ | `AppColors.background` vs `surface` |

---

## Provider Quick API

### CanvasProvider

```dart
// Drawing
changeActiveColor(int argb)
changeDrawingTool(DrawingTool tool)
drawPixel(row, col) / erasePixel(row, col)
handlePixelDrag(row, col)
beginStroke() / endStroke()
clearCanvas()

// Grid & templates
changeGridSize(int size)
loadTemplate(pixels: ..., gridSize: ...)

// History
undo() / redo()
bool canUndo / canRedo

// Read
CanvasState state
int filledPixelCount / totalPixelCount
```

### PaletteProvider

```dart
selectPreset(int slotIndex)      // 0..4
setCustomColor(int argb)         // slot 5
bool isCustomSelected
int customColor
```

### ThemeProvider

```dart
ThemeMode themeMode
String themeModeLabel
Future<void> setThemeMode(ThemeMode mode)
```

### MotifProvider

```dart
bool isExporting
Future<ExportResult> exportPng(CanvasState state)
Future<ExportResult> exportSvg(CanvasState state)
```

---

## Common Development Tasks

### Add a new preset color

1. Add to `ColorConstants.drawingPalette`.
2. Update `_colorName()` in `color_palette.dart` if needed.
3. Adjust `PaletteProvider.customSlotIndex` if count changes.

### Change app icon

1. Replace `assets/icon/app_icon.png` (1024×1024 recommended, safe margin).
2. Run `dart run flutter_launcher_icons`.
3. Reinstall app on device.

### Add a template

1. Define pattern in `TemplateService` (ASCII grid in `PixelTemplate`).
2. Template auto-appears in `TemplatesScreen` grid.

### Run on device

```bash
flutter devices
flutter run -d <device-id>
```

Hot reload: `r` · Hot restart: `R`

---

## Performance Rules (Do Not Break)

1. Never `context.watch<CanvasProvider>()` on the full grid — use per-cell `select`.
2. Never save undo history on every `drawPixel` during drag — use stroke batching.
3. Never put theme logic in `CanvasProvider`.
4. Never mutate `CanvasState.pixels` in place — always `copyWith` / `withPixelAt`.
5. Keep export logic in services, not widgets.

---

## Test Commands

```bash
flutter test                              # all tests
flutter test test/canvas_provider_undo_test.dart
flutter test test/template_service_test.dart
flutter analyze
```

---

## Related Files

| Topic | Primary files |
|-------|---------------|
| Drawing | `canvas_provider.dart`, `pixel_grid.dart` |
| Undo | `canvas_state.dart` (snapshot), `canvas_provider.dart` |
| Themes | `theme_provider.dart`, `theme_preferences.dart`, `app_theme.dart` |
| Templates | `template_service.dart`, `templates_screen.dart` |
| Export | `export_service.dart`, `svg_generator.dart` |
| Icons | `pubspec.yaml` → `flutter_launcher_icons`, `assets/icon/` |
