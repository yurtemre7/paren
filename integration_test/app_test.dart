import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'utils/paren_tester_ext.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('app tests', () {
    testWidgets('open app test', (tester) async {
      await tester.startApp();

      expect(find.text('€1.00'), findsOneWidget);
    });

    testWidgets('swap currency test', (tester) async {
      await tester.startApp();

      var swapFinder = find.byKey(const Key('swap_button'));
      await tester.tap(swapFinder);
      await tester.pumpAndSettle();
      expect(find.text('€1.00'), findsOneWidget);
    });
  });
}
