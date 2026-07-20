import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/pixel_template.dart';
import 'template_preview.dart';

/// Material 3 card tile for selecting a pixel template.
class TemplateCard extends StatelessWidget {
  const TemplateCard({
    required this.template,
    required this.onTap,
    super.key,
  });

  final PixelTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: '${template.name} template',
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 1,
        shadowColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: theme.colorScheme.primaryContainer
              .withValues(alpha: 0.45),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: TemplatePreview(template: template),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  '${template.emoji} ${template.name}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${template.designGridSize}×${template.designGridSize} design',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
