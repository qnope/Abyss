class_name Texts
extends RefCounted
## The game's texts in the language of the TranslationServer (AppLocale
## chooses it): `Texts.t(&"unitScoutCount", {"count": 3})` is "3 éclaireurs".
##
## The key is the ARB key of lib/presentation/l10n, the translation its ICU
## message (the .po files, written by tool/arb_to_po.py), formatted by
## IcuFormat. An unknown key or a missing argument logs an error, which fails
## the test that renders it, and the key itself is shown in its place.


## The text of `key`, its arguments (`args`) written in.
static func t(key: StringName, args: Dictionary = {}) -> String:
	var message := String(TranslationServer.translate(key))
	if message == String(key):
		push_error("Texts: no translation for \"%s\"" % key)
		return message
	return IcuFormat.format(message, args, TranslationServer.get_locale())


## Whether `key` has a translation in `locale` ("fr", "en", "es"), whatever
## language is on.
static func has(key: StringName, locale: String) -> bool:
	var translation := TranslationServer.get_translation_object(locale)
	return translation != null and not String(translation.get_message(key)).is_empty()
