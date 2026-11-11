class_name PluralRules
extends RefCounted
## The plural category of a count in each language of the game, the rules
## Flutter's intl applies: French reads 0 and 1 as singular ("one"), English
## and Spanish only 1; every other count is "other". An unknown language
## follows English. An exact `=N` case of a message is tried first, by
## IcuFormat.


## "one" or "other" for `count` in `locale` ("fr", "fr_CA"...).
static func category(locale: String, count: int) -> String:
	var singular := count == 0 or count == 1 if locale.begins_with("fr") else count == 1
	return "one" if singular else "other"
