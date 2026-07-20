import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Primary landing screen for the application.
///
/// Currently a scaffold shell — canvas, toolbar, and palette widgets
/// will be composed here in subsequent implementation phases.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      // Canvas, tool palette, and export controls will be added here.
      body: const SizedBox.shrink(),
    );
  }
}
