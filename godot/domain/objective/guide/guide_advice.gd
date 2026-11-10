class_name GuideAdvice
extends RefCounted
## lib/domain/objective/guide/guide_advice.dart: what the guide of the
## tutorial says, and what its halo surrounds.

var message: GuideMessage
var target: GuideTarget


func _init(message_: GuideMessage, target_: GuideTarget) -> void:
	message = message_
	target = target_


## `operator ==`: the same message and target.
func equals(other: Variant) -> bool:
	if not other is GuideAdvice:
		return false
	var advice: GuideAdvice = other
	return advice.message.equals(message) and advice.target.equals(target)


## `hashCode`: the same for equal advice, though not Dart's number.
func hash_code() -> int:
	return hash([message.hash_code(), target.hash_code()])


func _to_string() -> String:
	return "GuideAdvice(%s, %s)" % [message, target]
