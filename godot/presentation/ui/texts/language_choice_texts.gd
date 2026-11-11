class_name LanguageChoiceTexts
extends RefCounted
## lib/presentation/extensions/language_choice_extensions.dart: how each
## choice of language is named to the player.

const _ENDONYMS: Dictionary[LanguageChoice.Value, String] = {
	LanguageChoice.Value.FRENCH: "Français",
	LanguageChoice.Value.ENGLISH: "English",
	LanguageChoice.Value.SPANISH: "Español",
}


## `choice.endonym`: the language named in itself, never translated, so a
## player stuck in a language they cannot read still finds their own. Null
## (not a String) for AUTOMATIC, which is no language.
static func endonym(choice: LanguageChoice.Value) -> Variant:
	return _ENDONYMS.get(choice)


## `choice.label(l10n)`: the endonym, or "Automatique" in the language on.
static func label(choice: LanguageChoice.Value) -> String:
	if _ENDONYMS.has(choice):
		return _ENDONYMS[choice]
	return Texts.t(&"settingsLanguageAutomatic")
