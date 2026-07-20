import 'package:flutter/foundation.dart';

/// Manages palette slot selection and the user-defined custom paint color.
///
/// Keeps custom-color UI state out of [CanvasProvider] so canvas drawing
/// performance and template loading stay unaffected.
class PaletteProvider extends ChangeNotifier {
  /// Slot index for the custom color swatch (after all preset swatches).
  static const int customSlotIndex = 5;

  /// Default custom color — purple, distinct from preset swatches.
  static const int defaultCustomColor = 0xFF8E24AA;

  int _customColor = defaultCustomColor;

  /// Index of the selected preset swatch, or [customSlotIndex] for custom.
  int _selectedSlot = 0;

  /// User-picked ARGB color shown on the custom swatch.
  int get customColor => _customColor;

  /// Which palette slot is active (preset index or [customSlotIndex]).
  int get selectedSlot => _selectedSlot;

  /// Whether the custom color swatch is the active selection.
  bool get isCustomSelected => _selectedSlot == customSlotIndex;

  /// Selects a preset swatch by [slotIndex] (0 … preset count − 1).
  void selectPreset(int slotIndex) {
    assert(slotIndex >= 0 && slotIndex < customSlotIndex);
    if (_selectedSlot == slotIndex) return;
    _selectedSlot = slotIndex;
    notifyListeners();
  }

  /// Updates the custom color and selects the custom slot.
  void setCustomColor(int argb) {
    final colorChanged = _customColor != argb;
    final slotChanged = _selectedSlot != customSlotIndex;
    _customColor = argb;
    _selectedSlot = customSlotIndex;
    if (colorChanged || slotChanged) {
      notifyListeners();
    }
  }
}
