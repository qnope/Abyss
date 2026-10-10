import '../event/random_event_type.dart';
import 'action_result.dart';

/// Outcome of choosing for a random event: the event settled.
class ChooseEventResult extends ActionResult {
  final RandomEventType event;

  const ChooseEventResult.success(this.event) : super.success();
}
