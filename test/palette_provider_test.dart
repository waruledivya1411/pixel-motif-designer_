import 'package:flutter_test/flutter_test.dart';

import 'package:pixel_motif_designer/providers/palette_provider.dart';

void main() {
  test('customSlotIndex is after five preset swatches', () {
    expect(PaletteProvider.customSlotIndex, 5);
  });

  test('selectPreset updates slot without touching custom color', () {
    final provider = PaletteProvider();
    const custom = 0xFF123456;

    provider.setCustomColor(custom);
    provider.selectPreset(2);

    expect(provider.selectedSlot, 2);
    expect(provider.isCustomSelected, isFalse);
    expect(provider.customColor, custom);
  });

  test('setCustomColor selects custom slot', () {
    final provider = PaletteProvider();
    provider.selectPreset(0);

    provider.setCustomColor(0xFFABCDEF);

    expect(provider.isCustomSelected, isTrue);
    expect(provider.customColor, 0xFFABCDEF);
  });
}
