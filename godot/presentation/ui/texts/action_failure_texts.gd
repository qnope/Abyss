class_name ActionFailureTexts
extends RefCounted
## lib/presentation/extensions/action_failure_extensions.dart: why an action
## was refused, told to the player in the language on.


## `failure.message(l10n)`.
static func message(failure: ActionFailure.Value) -> String:
	return Texts.t(TextKeys.of("actionFailure", ActionFailure.Value, failure))


## `result.failureMessage(l10n)`: why the action failed, or a generic
## refusal when it gave no reason.
static func failure_message(result: ActionResult) -> String:
	if result.reason == null:
		return Texts.t(&"actionFailureUnknown")
	var reason: ActionFailure.Value = result.reason
	return message(reason)
