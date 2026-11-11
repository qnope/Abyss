class_name AppLocale
extends RefCounted
## The language the game speaks (lib/presentation/l10n/abyss_locale.dart and
## language_choice_locale.dart): the player's choice, or the device's while
## the choice is AUTOMATIC. French and Spanish devices get their language;
## every other device falls back to English. It sets the TranslationServer
## at startup and each time the player picks another language, which tells
## every node (NOTIFICATION_TRANSLATION_CHANGED) to write its texts again.

## The languages the game speaks, with a .po file each.
const SUPPORTED: Array[String] = ["fr", "en", "es"]
const _FALLBACK := "en"

var _settings: LanguageSettings
var _device_language: String
var _locale: String


## Follows `settings`, resolving AUTOMATIC from `device_language`, the
## system's language by default.
func _init(settings: LanguageSettings, device_language: String = OS.get_locale_language()) -> void:
	_settings = settings
	_device_language = device_language
	_apply(settings.choice())
	settings.changed.connect(_apply)


## The language on: "fr", "en" or "es".
func locale() -> String:
	return _locale


## `AbyssLocale.resolve`, with the forced locale of the choice
## (`LanguageChoice.locale`): the choice's own language, else the device's
## when the game speaks it, else English.
static func resolve(choice: LanguageChoice.Value, device_language: String) -> String:
	var code: Variant = LanguageChoice.code(choice)
	if code is String:
		return code
	return device_language if SUPPORTED.has(device_language) else _FALLBACK


## Puts the game back in French, the language the tests expect: for
## process_resets.gd.
static func debug_reset() -> void:
	TranslationServer.set_locale("fr")


func _apply(choice: LanguageChoice.Value) -> void:
	_locale = resolve(choice, _device_language)
	TranslationServer.set_locale(_locale)
