import '../unit/unit_type.dart';
import 'action_result.dart';

class DescendResult extends ActionResult {
  final int? targetLevel;
  final Map<UnitType, int>? unitsSent;

  const DescendResult.success({
    required int this.targetLevel,
    required Map<UnitType, int> this.unitsSent,
  }) : super.success();

  const DescendResult.failure(super.reason)
      : targetLevel = null,
        unitsSent = null,
        super.failure();
}
