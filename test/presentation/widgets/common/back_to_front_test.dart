import 'package:abyss/presentation/widgets/common/back_to_front.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('backToFront', () {
    test('sorts by ascending depth', () {
      expect(backToFront([3, 1, 2], (n) => n.toDouble()), [1, 2, 3]);
    });

    test('keeps the given order between equal depths', () {
      final items = ['b1', 'a1', 'b2', 'a2', 'b3'];
      expect(backToFront(items, (s) => s.startsWith('a') ? 0.0 : 1.0), [
        'a1',
        'a2',
        'b1',
        'b2',
        'b3',
      ]);
    });

    test('leaves the given items untouched', () {
      final items = [2, 1];
      backToFront(items, (n) => n.toDouble());
      expect(items, [2, 1]);
    });
  });
}
