class_name TransitionBaseTexts
extends RefCounted
## lib/presentation/extensions/transition_base_type_extensions.dart: the
## posts that lead from a level to the next, named in the language on.


## `type.displayName(l10n)`: "Faille Abyssale".
static func display_name(type: TransitionBaseType.Value) -> String:
	return Texts.t(TextKeys.of("transitionBase", TransitionBaseType.Value, type, "Name"))


## `type.description(l10n)`: "Passage vers les profondeurs".
static func description(type: TransitionBaseType.Value) -> String:
	return Texts.t(TextKeys.of("transitionBase", TransitionBaseType.Value, type, "Description"))
