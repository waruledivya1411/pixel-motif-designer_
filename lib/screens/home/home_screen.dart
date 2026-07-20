import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../widgets/pixel_grid.dart';

/// Primary landing screen for the application.
///
/// Composes the scaffold shell with a centered [PixelGrid]. Toolbars,
/// palette, and export controls will be added in later phases.
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
          child: PixelGrid(),
        ),
      ),
    );
  }
}
