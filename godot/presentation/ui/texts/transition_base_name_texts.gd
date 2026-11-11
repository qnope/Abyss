class_name TransitionBaseNameTexts
extends RefCounted
## lib/presentation/extensions/transition_base_name_extensions.dart: the name
## of a transition base in the language on ("Faille Bêta"), and of one a save
## stored (a passage, a capture), the volcanic kernel included.

const _FAILLE: Array[StringName] = [&"baseFailleAlpha", &"baseFailleBeta", &"baseFailleGamma", &"baseFailleDelta"]
const _CHEMINEE: Array[StringName] = [&"baseChemineePrimary", &"baseChemineeSecondary", &"baseChemineeTertiary"]


## `name.displayName(l10n)`: a base named by its type and its rank.
static func display_name(base: TransitionBaseName) -> String:
	var known := _FAILLE if base.type == TransitionBaseType.Value.FAILLE else _CHEMINEE
	if base.rank < known.size():
		return Texts.t(known[base.rank])
	return Texts.t(&"baseOtherName", {"type": TransitionBaseTexts.display_name(base.type), "number": base.rank + 1})


## `baseNameLabel`: the name of a base as a save [param stored] it, in the
## language on. A text naming no known base is shown as it is.
static func label(stored: String) -> String:
	if stored == CaptureEntry.VOLCANIC_KERNEL:
		return BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL)
	var base := TransitionBaseName.parse(stored)
	return stored if base == null else display_name(base)
