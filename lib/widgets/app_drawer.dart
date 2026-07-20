import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../screens/templates/templates_screen.dart';
import 'grid_size_selector.dart';

/// Navigation drawer for canvas-level settings.
///
/// Mirrors the main screen's card-based Material 3 styling so the drawer
/// feels like part of the same product surface, not a default system menu.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppConstants.borderRadius),
          bottomRight: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(theme: theme),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                children: [
                  _DrawerNavTile(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _DrawerNavTile(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Templates',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const TemplatesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppConstants.paddingSmall,
                      bottom: AppConstants.paddingSmall,
                    ),
                    child: Text(
                      'Canvas settings',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const GridSizeSelector(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Branded drawer header aligned with the app bar and editor panels.
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMedium,
        AppConstants.paddingLarge,
        AppConstants.paddingMedium,
        AppConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: theme.colorScheme.onPrimary,
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Canvas settings',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        tileColor: theme.colorScheme.surface,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
      ),
    );
  }
}
