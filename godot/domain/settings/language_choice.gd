class_name LanguageChoice
extends RefCounted
## lib/domain/settings/language_choice.dart: the language the player wants
## the game in. AUTOMATIC follows the device; the others force a language
## whatever the device speaks.

enum Value { AUTOMATIC, FRENCH, ENGLISH, SPANISH }

## The stable code each choice is saved under; none for AUTOMATIC, which is
## never stored.
const _CODES: Dictionary[Value, String] = {
	Value.FRENCH: "fr",
	Value.ENGLISH: "en",
	Value.SPANISH: "es",
}


## `choice.code`: a String, or null for AUTOMATIC.
static func code(choice: Value) -> Variant:
	return _CODES.get(choice)


## `fromCode`: the choice saved under `saved` (a String or null);
## AUTOMATIC for a missing or unknown one.
static func from_code(saved: Variant) -> Value:
	var found: Variant = _CODES.find_key(saved) if saved is String else null
	return Value.AUTOMATIC if found == null else found
