class_name TerrainTexts
extends RefCounted
## lib/presentation/extensions/terrain_type_extensions.dart: the name of a
## terrain, in the language on. The sea floor has one kind, the plain.


## `type.label(l10n)`: "Plaine".
static func label(_type: TerrainType.Value) -> String:
	return Texts.t(&"terrainPlain")
