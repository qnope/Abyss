class_name BuildingColors
## The colour of each building, in the sheets and cards that show it
## (lib/presentation/extensions/building_type_extensions.dart:
## BuildingTypeColor). It is the colour of the building's stand-in in the
## world too, and the Flutter one where the eleven stayed apart: the Flutter
## palette gave the coral mine and the citadel the same rose, the barracks
## nearly the mine's, the descent module nearly the ore extractor's and the
## kernel the solar panel's yellow, so those four are new. The world keeps its
## own copy (`WorldPalette`, which may not read this layer); a test in `app/`
## holds the two together.


## `type.color`.
static func of(type: BuildingType.Value) -> Color:
	match type:
		BuildingType.Value.HEADQUARTERS:
			return AbyssColors.BIOLUM_PURPLE
		BuildingType.Value.ALGAE_FARM:
			return AbyssColors.ALGAE_GREEN
		BuildingType.Value.CORAL_MINE:
			return AbyssColors.CORAL_PINK
		BuildingType.Value.CORAL_CITADEL:
			return Color("ffccbc")
		BuildingType.Value.ORE_EXTRACTOR:
			return AbyssColors.ORE_BLUE
		BuildingType.Value.SOLAR_PANEL:
			return AbyssColors.ENERGY_YELLOW
		BuildingType.Value.LABORATORY:
			return AbyssColors.BIOLUM_TEAL
		BuildingType.Value.BARRACKS:
			return Color("e040fb")
		BuildingType.Value.DESCENT_MODULE:
			return Color("b0bec5")
		BuildingType.Value.PRESSURE_CAPSULE:
			return AbyssColors.BIOLUM_CYAN
	return Color("ff6d00")
