class_name CellContentTexts
extends RefCounted
## lib/presentation/extensions/cell_content_type_extensions.dart: what a cell
## of the map holds, named in the language on.


## `content.label(l10n)`: "Vide", "Ruines", "Épave"... The volcano and its
## parts are the kernel's name, a post is a Faille's.
static func label(content: CellContentType.Value) -> String:
	match content:
		CellContentType.Value.RESOURCE_BONUS:
			return Texts.t(&"cellContentResourceBonus")
		CellContentType.Value.RUINS:
			return Texts.t(&"cellContentRuins")
		CellContentType.Value.MONSTER_LAIR:
			return Texts.t(&"cellContentMonsterLair")
		CellContentType.Value.TRANSITION_BASE:
			return TransitionBaseTexts.display_name(TransitionBaseType.Value.FAILLE)
		CellContentType.Value.PASSAGE:
			return Texts.t(&"cellContentPassage")
		CellContentType.Value.VOLCANIC_KERNEL, CellContentType.Value.VOLCANIC_KERNEL_PART:
			return BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL)
		CellContentType.Value.WRECK:
			return Texts.t(&"randomEventWreckLabel")
	return Texts.t(&"cellContentEmpty")
