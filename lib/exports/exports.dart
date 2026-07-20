/// Public API barrel — single import point for commonly used modules.
///
/// Use this in feature files to reduce import clutter while keeping
/// internal module boundaries intact.
library;

export '../app.dart';
export '../core/constants/constants.dart';
export '../core/theme/theme.dart';
export '../models/models.dart';
export '../providers/providers.dart';
export '../screens/screens.dart';
export '../services/services.dart';
export '../widgets/widgets.dart';
