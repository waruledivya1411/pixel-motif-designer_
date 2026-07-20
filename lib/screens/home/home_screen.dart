import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/color_palette.dart';
import '../../widgets/editing_toolbar.dart';
import '../../widgets/editor_panel.dart';
import '../../widgets/export_section.dart';
import '../../widgets/pixel_counter_card.dart';
import '../../widgets/pixel_grid.dart';

/// Primary landing screen for the application.
///
/// Fixed vertical layout (no scroll): palette → toolbar → counter → grid →
/// export. Grid size lives in the navigation drawer.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth.clamp(
              0.0,
              AppConstants.maxContentWidth,
            );
            final gridMaxWidth = contentWidth - AppConstants.paddingMedium * 4;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth,
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
                      Expanded(
                        child: EditorPanel(
                          semanticLabel: 'Pixel canvas',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const PixelCounterCard(),
                              const SizedBox(height: AppConstants.paddingSmall),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, gridConstraints) {
                                    return Center(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: PixelGrid(
                                          maxWidth: gridMaxWidth.clamp(
                                            0,
                                            gridConstraints.maxWidth,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
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
