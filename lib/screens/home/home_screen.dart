import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../widgets/color_palette.dart';
import '../../widgets/editing_toolbar.dart';
import '../../widgets/export_section.dart';
import '../../widgets/pixel_grid.dart';

/// Primary landing screen for the application.
///
/// Layout: AppBar → [ColorPalette] → [EditingToolbar] → [PixelGrid] → [ExportSection].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorPalette(),
              SizedBox(height: AppConstants.paddingMedium),
              EditingToolbar(),
              SizedBox(height: AppConstants.paddingLarge),
              PixelGrid(),
              SizedBox(height: AppConstants.paddingLarge),
              ExportSection(),
            ],
          ),
        ),
      ),
    );
  }
}
