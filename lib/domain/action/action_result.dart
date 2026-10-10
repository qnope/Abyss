import 'action_failure.dart';

class ActionResult {
  final bool isSuccess;

  /// Why the action failed; `null` when it succeeded.
  final ActionFailure? reason;

  const ActionResult.success() : isSuccess = true, reason = null;

  const ActionResult.failure(ActionFailure this.reason) : isSuccess = false;
}
