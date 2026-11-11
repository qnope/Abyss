class_name PassageName
extends RefCounted
## The name of the post above a passage, in the language on
## (lib/presentation/extensions/transition_base_name_extensions.dart,
## `baseNameLabel`, for what a passage stores): "Faille Alpha", "Cheminée
## Primaire", or the text as it is when it names no known post.

const _FAILLE: Array[StringName] = [
	&"baseFailleAlpha", &"baseFailleBeta", &"baseFailleGamma", &"baseFailleDelta",
]
const _CHEMINEE: Array[StringName] = [
	&"baseChemineePrimary", &"baseChemineeSecondary", &"baseChemineeTertiary",
]


## The name of the post a passage [param stored] (a code, an older French
## name, or null when the cell holds none) comes from.
static func of(stored: Variant) -> String:
	if stored == null:
		return Texts.t(&"screenUnknownPassage")
	var text: String = stored
	var base := TransitionBaseName.parse(text)
	if base == null:
		return text
	var known := _FAILLE if base.type == TransitionBaseType.Value.FAILLE else _CHEMINEE
	if base.rank < known.size():
		return Texts.t(known[base.rank])
	return Texts.t(&"baseOtherName", {
		"type": TransitionBaseTexts.display_name(base.type), "number": base.rank + 1,
	})
