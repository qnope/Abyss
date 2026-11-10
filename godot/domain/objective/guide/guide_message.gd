class_name GuideMessage
extends RefCounted
## lib/domain/objective/guide/guide_message.dart: what the guide of the
## tutorial, the octopus archivist, says: one lesson per objective it
## follows, then a word for each situation that holds an objective back, or
## that threatens what was taken. The presentation words it from its
## figures.
##
## Each message of that sealed family, and of its part
## guide_campaign_messages.dart, has a file of its own (guide_lesson.gd...).
## A message keeps its figures as Dart prints them ("ObjectiveId.mines",
## "12", "true", -1 for a null): two messages of a kind with the same texts
## have the same figures.


## `_figures`: the figures the message carries, which tell two messages
## apart, as Dart prints each.
func _figures() -> PackedStringArray:
	return PackedStringArray()


## `operator ==`: a message of the same kind with the same figures.
func equals(other: Variant) -> bool:
	if not other is GuideMessage:
		return false
	var message: GuideMessage = other
	return message.get_script() == get_script() and message._figures() == _figures()


## `hashCode`: the same for equal messages, though not Dart's number.
func hash_code() -> int:
	return hash([str(self)])


## `$runtimeType$_figures`, as Dart prints a list.
func _to_string() -> String:
	var script: Script = get_script()
	return "%s[%s]" % [script.get_global_name(), ", ".join(_figures())]


## How Dart prints the enum `value` of `enumeration`, named `type`.
static func enum_text(type: String, enumeration: Dictionary, value: int) -> String:
	return "%s.%s" % [type, DartEnum.name_of(enumeration, value)]


## How Dart prints an int that may be null, as its message keeps it: -1.
static func or_minus_one(value: Variant) -> String:
	return str(-1 if value == null else value)
