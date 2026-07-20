import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/theme_provider.dart';
import '../screens/templates/templates_screen.dart';
import 'appearance_sheet.dart';
import 'grid_size_selector.dart';

/// Navigation drawer for canvas-level settings.
///
/// Uses the brand blue palette via [ThemeData] so drawer content matches
/// the app bar, buttons, and templates gallery.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.primaryContainer,
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
                  const _AppearanceDrawerTile(),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppConstants.paddingSmall,
                      bottom: AppConstants.paddingSmall,
                    ),
                    child: Text(
                      'Canvas settings',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
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

/// Branded drawer header aligned with the blue app bar.
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
        color: theme.colorScheme.primary,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.35),
              ),
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
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Design your pixel motifs',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
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

/// Drawer entry that shows the active theme mode as a subtitle.
class _AppearanceDrawerTile extends StatelessWidget {
  const _AppearanceDrawerTile();

  @override
  Widget build(BuildContext context) {
    return _DrawerNavTile(
      icon: Icons.palette_outlined,
      label: 'Appearance',
      subtitle: context.select<ThemeProvider, String>(
        (provider) => provider.themeModeLabel,
      ),
      onTap: () {
        Navigator.of(context).pop();
        showAppearanceSheet(context);
      },
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 1,
        shadowColor: theme.colorScheme.primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          title: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
        ),
      ),
    );
  }
}
