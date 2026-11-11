class_name BuildingTexts
extends RefCounted
## lib/presentation/extensions/building_type_extensions.dart (BuildingTypeInfo):
## what a building is called and what it does, in the language on.


## `type.displayName(l10n)`: "Quartier Général".
static func display_name(type: BuildingType.Value) -> String:
	return Texts.t(TextKeys.of("building", BuildingType.Value, type, "Name"))


## `type.description(l10n)`. The headquarters' tells the flat income it makes.
static func description(type: BuildingType.Value) -> String:
	var income := ProductionCalculator.HEADQUARTERS_INCOME
	var args := {}
	if type == BuildingType.Value.HEADQUARTERS:
		args = {
			"coral": income.get(ResourceType.Value.CORAL, 0),
			"ore": income.get(ResourceType.Value.ORE, 0),
		}
	return Texts.t(TextKeys.of("building", BuildingType.Value, type, "Description"), args)
