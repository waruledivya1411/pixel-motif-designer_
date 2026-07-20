import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../widgets/color_palette.dart';
import '../../widgets/editing_toolbar.dart';
import '../../widgets/pixel_grid.dart';

/// Primary landing screen for the application.
///
/// Layout: AppBar → [ColorPalette] → [EditingToolbar] → [PixelGrid].
/// Export controls will be added in later phases.
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
            ],
          ),
        ),
      ),
    );
  }
}
