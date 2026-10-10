import 'dart:io';

import 'package:abyss/presentation/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matches the version declared in pubspec.yaml', () {
    final line = File(
      'pubspec.yaml',
    ).readAsLinesSync().firstWhere((line) => line.startsWith('version:'));
    final declared = line.substring('version:'.length).trim();
    expect(declared.split('+').first, appVersion);
  });
}
