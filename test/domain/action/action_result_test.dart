import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action_result.dart';

void main() {
  group('ActionResult', () {
    test('success has isSuccess true and reason null', () {
      const result = ActionResult.success();
      expect(result.isSuccess, true);
      expect(result.reason, isNull);
    });

    test('failure has isSuccess false and the given reason', () {
      final result = ActionResult.failure('not enough resources');
      expect(result.isSuccess, false);
      expect(result.reason, 'not enough resources');
    });
  });
}
