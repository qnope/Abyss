import 'package:flutter_test/flutter_test.dart';

/// Asks the app to reduce motion, as the system setting does: the menu
/// backdrop then stands still, so `pumpAndSettle` can settle on it.
void reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

/// Asks the app to reduce motion in every test of the enclosing group, so
/// screens showing the map (whose sea never stops moving) can settle.
void reduceMotionInEveryTest() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => binding.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true));
  tearDown(binding.platformDispatcher.clearAccessibilityFeaturesTestValue);
}
