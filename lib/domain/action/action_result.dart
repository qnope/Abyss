class ActionResult {
  final bool isSuccess;
  final String? reason;

  const ActionResult.success() : isSuccess = true, reason = null;

  const ActionResult.failure(this.reason) : isSuccess = false;
}
