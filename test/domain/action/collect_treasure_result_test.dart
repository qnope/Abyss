import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action_result.dart';
import 'package:abyss/domain/action/collect_treasure_result.dart';
import 'package:abyss/domain/resource/resource_type.dart';

void main() {
  group('CollectTreasureResult', () {
    test('success exposes isSuccess true and the provided deltas map', () {
      const deltas = {ResourceType.algae: 5, ResourceType.ore: 2};
      const result = CollectTreasureResult.success(deltas);

      expect(result.isSuccess, true);
      expect(result.reason, isNull);
      expect(result.deltas, deltas);
    });

    test('failure exposes isSuccess false, the reason and empty deltas', () {
      const result = CollectTreasureResult.failure('reason');

      expect(result.isSuccess, false);
      expect(result.reason, 'reason');
      expect(result.deltas, isEmpty);
    });

    test('is assignable to an ActionResult variable', () {
      const CollectTreasureResult collect = CollectTreasureResult.success({});
      const ActionResult result = collect;

      expect(result.isSuccess, true);
    });
  });
}
