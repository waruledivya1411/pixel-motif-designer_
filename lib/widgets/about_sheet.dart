import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Material 3 bottom sheet with app information for the navigation drawer.
Future<void> showAboutSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _AboutSheet(),
  );
}

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingMedium,
            AppConstants.paddingSmall,
            AppConstants.paddingMedium,
            AppConstants.paddingLarge,
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                'About',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              _AboutHeader(theme: theme),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                AppConstants.appDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'Features',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              ...AppConstants.appFeatures.map(
                (feature) => _AboutFeatureRow(
                  theme: theme,
                  label: feature,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              _AboutInfoCard(
                theme: theme,
                icon: Icons.person_outline_rounded,
                label: 'Author',
                value: AppConstants.appAuthor,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              _AboutInfoCard(
                theme: theme,
                icon: Icons.mail_outline_rounded,
                label: 'Contact',
                value: AppConstants.appContactEmail,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: theme.colorScheme.onPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Design · Export · Create',
                  style: theme.textTheme.bodySmall?.copyWith(
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

class _AboutFeatureRow extends StatelessWidget {
  const _AboutFeatureRow({
    required this.theme,
    required this.label,
  });

  final ThemeData theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutInfoCard extends StatelessWidget {
  const _AboutInfoCard({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
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
