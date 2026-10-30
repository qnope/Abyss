import 'package:flutter_test/flutter_test.dart';

/// Lets the bitmaps rasterized in the background (see BackgroundTasks)
/// come in, pumping a frame after each wait, until [done] holds or a few
/// seconds pass.
Future<void> settleRasters(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 150 && !done(); i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }
}
