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
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TemplatePreview(template: template),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  '${template.emoji} ${template.name}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${template.designGridSize}×${template.designGridSize} design',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
