import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// A consistent Material 3 surface wrapper for editor sections.
///
/// Groups related controls with shared padding, corner radius, and elevation
/// so the screen reads as a clear vertical hierarchy without adding state.
class EditorPanel extends StatelessWidget {
  const EditorPanel({
    required this.child,
    this.semanticLabel,
    super.key,
  });

  final Widget child;

  /// Accessibility label describing the panel's purpose.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.85),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: child,
        ),
      ),
    );
  }
}
