class_name ActionResult
extends RefCounted
## lib/domain/action/action_result.dart: what an action answers, a success
## or a failure with its reason. The results that carry more (a fight, a
## loot) extend it, their constructors passing the reason up: null for a
## success.

var is_success: bool
## Why the action failed (an ActionFailure.Value); null when it succeeded.
var reason: Variant


## `reason_` null is a success, an ActionFailure.Value a failure.
func _init(reason_: Variant = null) -> void:
	is_success = reason_ == null
	reason = reason_


## `ActionResult.success()`.
static func success() -> ActionResult:
	return ActionResult.new()


## `ActionResult.failure(reason)`.
static func failure(reason_: ActionFailure.Value) -> ActionResult:
	return ActionResult.new(reason_)
