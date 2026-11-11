class_name BuildingDegradationTexts
extends RefCounted
## lib/presentation/extensions/building_degradation_texts.dart: what a
## degraded building suffers, in words, in the language on.


## `type.degradedEffect(l10n)`.
static func degraded_effect(type: BuildingType.Value) -> String:
	return Texts.t(_key(type))


static func _key(type: BuildingType.Value) -> StringName:
	match type:
		BuildingType.Value.HEADQUARTERS, BuildingType.Value.ALGAE_FARM, \
		BuildingType.Value.CORAL_MINE, BuildingType.Value.ORE_EXTRACTOR:
			return &"buildingDegradedProduction"
		BuildingType.Value.SOLAR_PANEL:
			return &"buildingDegradedSolar"
		BuildingType.Value.LABORATORY:
			return &"buildingDegradedLaboratory"
		BuildingType.Value.BARRACKS:
			return &"buildingDegradedBarracks"
		BuildingType.Value.CORAL_CITADEL:
			return &"buildingDegradedCitadel"
	return &"buildingDegradedUnusable"
