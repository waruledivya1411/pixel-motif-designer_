import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

/// Application entry point.
///
/// Keeps bootstrap concerns isolated: binding initialization, orientation,
/// and launching the root widget. No business logic lives here.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for a consistent canvas experience on phones.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const PixelMotifApp());
}
