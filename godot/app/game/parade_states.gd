class_name ParadeStates
extends RefCounted
## What the parade ground shows, read from the game and written in the
## language on: the world draws it and writes no text of its own.


## One state for each of the six units, in order, from the [param roster]:
## the count serving, the green plus where the barracks lets recruit, and
## under the count the name in the singular or plural, or the barracks level a
## locked unit waits for.
static func squads(roster: ArmyRoster) -> Array[SquadState]:
	var states: Array[SquadState] = []
	for type: UnitType.Value in UnitType.Value.values():
		var locked := roster.is_locked(type)
		var count := roster.count_of(type)
		var caption := UnitArmyTexts.lock_pill(type) if locked else UnitArmyTexts.plaque_name(type, count)
		states.append(SquadState.new(type, count, locked, roster.can_recruit(type), caption))
	return states


## The barracks of the human player's base, with the signs of a plot that can
## be built on and of one a prerequisite holds back.
static func barracks(game: Game) -> PadState:
	var states := PadState.of_base(game.human_player().buildings, BaseReadiness.upgradable(game),
		BaseReadiness.locked(game))
	for state in states:
		if state.type == BuildingType.Value.BARRACKS:
			return state
	return PadState.new(BuildingType.Value.BARRACKS)
