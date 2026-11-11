class_name UnitColors
## The colour of each unit, in the sheets, cards and rows that show it
## (lib/presentation/extensions/unit_type_extensions.dart: UnitTypeColor). It
## is the colour of the unit's stand-in in the world too, and the hue the
## Flutter parade ground gave the squads (`AbyssArmyColors.of`), which reads
## on the dark sheets where the dark `UnitTypeColor` does not, apart from the
## harpoonist: its orange was nearly the dome breaker's, so it is red. The
## world keeps its own copy (`WorldPalette`, which may not read this layer); a
## test in `app/` holds the two together.


## `type.color`.
static func of(type: UnitType.Value) -> Color:
	match type:
		UnitType.Value.SCOUT:
			return AbyssArmyColors.SCOUT
		UnitType.Value.HARPOONIST:
			return Color("ff5252")
		UnitType.Value.GUARDIAN:
			return AbyssArmyColors.GUARDIAN
		UnitType.Value.DOME_BREAKER:
			return AbyssArmyColors.DOME_BREAKER
		UnitType.Value.ABYSS_ADMIRAL:
			return AbyssArmyColors.ABYSS_ADMIRAL
	return AbyssArmyColors.SABOTEUR
