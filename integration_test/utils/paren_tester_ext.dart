import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:paren/main.dart' as app;

extension ParenWidgetTester on WidgetTester {
  /// Starts the app
  ///
  /// Use for integration tests
  Future<void> startApp() async {
    app.main();
    await pumpAndSettle();
    // Give the app 2 seconds extra loading time :)!
    await Future.delayed(2.seconds);
  }
}
