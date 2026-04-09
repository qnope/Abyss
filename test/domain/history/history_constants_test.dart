import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/history/history_constants.dart';

void main() {
  group('history constants', () {
    test('kHistoryMaxEntries equals 100', () {
      expect(kHistoryMaxEntries, 100);
    });
  });
}
