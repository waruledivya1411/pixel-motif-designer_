import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixel_motif_designer/app.dart';
import 'package:pixel_motif_designer/core/constants/app_constants.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeScreen renders app title', (WidgetTester tester) async {
    await tester.pumpWidget(const PixelMotifApp());

    expect(find.text(AppConstants.appName), findsOneWidget);
  });
}
