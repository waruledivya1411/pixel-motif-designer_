import 'package:flutter/foundation.dart';

/// Manages the pixel grid state and drawing interactions.
///
/// Will hold the 2D color matrix, selected tool, and undo/redo stacks.
/// Separating grid state from UI widgets keeps the canvas performant
/// during continuous drawing by limiting rebuild scope.
class GridProvider extends ChangeNotifier {
  // Grid state and drawing logic will be implemented in a later phase.
}
