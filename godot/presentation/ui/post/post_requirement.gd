class_name PostRequirement
extends RefCounted
## The building to raise before going down through a post
## (lib/presentation/screens/game/game_screen_base_sheet.dart): the Descent
## Module for a Faille, the Pressure Capsule for a Cheminée.


## The building [param base] asks for.
static func building_for(base: TransitionBase) -> BuildingType.Value:
	if base.type == TransitionBaseType.Value.FAILLE:
		return BuildingType.Value.DESCENT_MODULE
	return BuildingType.Value.PRESSURE_CAPSULE


## Whether [param player] has raised it.
static func met_by(player: Player, base: TransitionBase) -> bool:
	return Building.level_in(player.buildings, building_for(base)) > 0
