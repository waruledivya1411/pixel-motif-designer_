import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/pixel_template.dart';
import '../../providers/canvas_provider.dart';
import '../../services/template_service.dart';
import '../../widgets/template_card.dart';

/// Gallery screen for built-in pixel templates.
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templates = TemplateService.templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixel Templates'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 520 ? 3 : 2;

            return Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TemplatesHeader(theme: theme),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppConstants.paddingMedium,
                        mainAxisSpacing: AppConstants.paddingMedium,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        final template = templates[index];
                        return TemplateCard(
                          template: template,
                          onTap: () => _handleTemplateTap(context, template),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleTemplateTap(
    BuildContext context,
    PixelTemplate template,
  ) async {
    final shouldLoad = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Load Template'),
          content: const Text(
            'Loading a template will clear your current canvas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Load'),
            ),
          ],
        );
      },
    );

    if (shouldLoad != true || !context.mounted) return;

    final canvasProvider = context.read<CanvasProvider>();
    final currentGridSize = canvasProvider.gridRows;
    var plan = TemplateService.planFor(
      template: template,
      currentGridSize: currentGridSize,
    );

    if (plan.requiresResize) {
      final suggestedSize = plan.targetGridSize;
      final shouldSwitch = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Load Template'),
            content: Text(
              'This template is designed for a larger canvas.\n'
              'Would you like to switch to $suggestedSize×$suggestedSize?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Switch & Load'),
              ),
            ],
          );
        },
      );

      if (shouldSwitch != true || !context.mounted) return;

      plan = TemplateService.planFor(
        template: template,
        currentGridSize: currentGridSize,
        overrideGridSize: suggestedSize,
      );
    }

    canvasProvider.loadTemplate(
      pixels: plan.pixels,
      gridSize: plan.targetGridSize,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${template.emoji} ${template.name} loaded')),
    );
    Navigator.of(context).pop();
  }
}

class _TemplatesHeader extends StatelessWidget {
  const _TemplatesHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pick a starter motif',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Templates load instantly onto your canvas with their original colors.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
