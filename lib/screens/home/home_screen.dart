import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../widgets/color_palette.dart';
import '../../widgets/editing_toolbar.dart';
import '../../widgets/editor_panel.dart';
import '../../widgets/export_section.dart';
import '../../widgets/pixel_grid.dart';

/// Primary landing screen for the application.
///
/// Layout: AppBar → [ColorPalette] → [EditingToolbar] → [PixelGrid] → [ExportSection].
/// Uses a scrollable, width-constrained column so content stays balanced on
/// small phones and larger devices without changing feature behavior.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppConstants.maxContentWidth,
                    minWidth: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const EditorPanel(
                        semanticLabel: 'Color palette',
                        child: ColorPalette(),
                      ),
                      const SizedBox(height: AppConstants.sectionSpacing),
                      const EditorPanel(
                        semanticLabel: 'Editing tools',
                        child: EditingToolbar(),
                      ),
                      const SizedBox(height: AppConstants.sectionSpacing),
                      EditorPanel(
                        semanticLabel: 'Pixel canvas',
                        child: PixelGrid(
                          maxWidth: constraints.maxWidth -
                              AppConstants.paddingMedium * 2 -
                              AppConstants.paddingMedium * 2,
                        ),
                      ),
                      const SizedBox(height: AppConstants.sectionSpacing),
                      const EditorPanel(
                        semanticLabel: 'Export options',
                        child: ExportSection(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
