class_name LanguageSettings
extends RefCounted
## lib/data/language_settings.dart: the language the player picked, kept
## across launches in a JSON file of `user://` (data/README.md, "The
## settings"): `{"format":1,"language":"fr"}`, the language left out while
## the device decides.
##
## `changed` tells each real change, so the app can switch language at
## once, as Dart's listeners hear it.

signal changed(choice: LanguageChoice.Value)

const PATH := "user://settings.json"
const FORMAT := 1

var path: String
var _choice: LanguageChoice.Value


## Reads the choice saved at `path_`. A file missing, unreadable, of a
## newer format or holding an unknown code reads as AUTOMATIC, as Dart
## falls back when its box cannot be opened.
func _init(path_ := PATH) -> void:
	path = path_
	var text: Variant = AtomicFile.read(path)
	var json := JSON.new()
	var saved: Variant = null
	if text is String and json.parse(str(text)) == OK and json.data is Dictionary:
		var settings: Dictionary = json.data
		if settings.get("format") == float(FORMAT):
			saved = settings.get("language")
	_choice = LanguageChoice.from_code(saved)


func choice() -> LanguageChoice.Value:
	return _choice


## Switches to `choice_` and saves it; AUTOMATIC erases the saved language
## so the device decides again. OK, or the error met while saving.
func choose(choice_: LanguageChoice.Value) -> Error:
	if choice_ == _choice:
		return OK
	_choice = choice_
	changed.emit(choice_)
	var settings := {"format": FORMAT}
	var code: Variant = LanguageChoice.code(choice_)
	if code != null:
		settings["language"] = code
	return AtomicFile.write(path, JSON.stringify(settings, "", false))
