import 'dart:io';

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

  test('coral_citadel.svg file size is under 7000 bytes', () {
    final file = File(assetPath);
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), lessThan(7000));
  });
}
