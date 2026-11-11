class_name MapLevelTexts
extends RefCounted
## lib/presentation/widgets/map/map_level_info.dart (MapLevelInfo.nameOf): how
## the map's depths, numbered from 1 at the surface, are named.

## Every depth, from the surface down to the core.
const LEVELS: Array[int] = [1, 2, 3]


## `MapLevelInfo.nameOf(l10n, level)`: "Surface", "Profondeurs", "Noyau".
static func name_of(level: int) -> String:
	match level:
		1:
			return Texts.t(&"mapLevelSurface")
		2:
			return Texts.t(&"mapLevelDepths")
	return Texts.t(&"mapLevelCore")
