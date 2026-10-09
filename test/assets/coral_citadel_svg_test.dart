import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const assetPath = 'assets/icons/buildings/coral_citadel.svg';

  testWidgets('coral_citadel.svg loads and contains mandatory palette', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final content = await rootBundle.loadString(assetPath);

      expect(content, contains('#F48FB1'));
      expect(content, contains('#1A237E'));

      final hasGradientId =
          content.contains('citadelPink') ||
          content.contains('citadelNavy') ||
          content.contains('citadelCrystal') ||
          content.contains('citadelAlgae');
      expect(hasGradientId, isTrue);
    });
  });

}
