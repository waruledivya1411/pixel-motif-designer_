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
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
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
