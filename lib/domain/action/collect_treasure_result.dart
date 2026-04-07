import '../resource/resource_type.dart';
import 'action_result.dart';

class CollectTreasureResult extends ActionResult {
  final Map<ResourceType, int> deltas;

  const CollectTreasureResult.success(this.deltas) : super.success();

  const CollectTreasureResult.failure(super.reason)
    : deltas = const {},
      super.failure();
}
