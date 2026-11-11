class_name AttackerNameTexts
extends RefCounted
## lib/presentation/extensions/attacker_name_texts.dart: the name of who
## attacked, or was attacked, as the reports show it: the guardians of the
## Faille in the language on, any other player by its own name.


## `attackerLabel(l10n, name)`.
static func label(name: String) -> String:
	return Texts.t(&"leviathanAttackerName") if name == LeviathanForce.ATTACKER_NAME else name
