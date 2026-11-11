class_name GuideAdvisor
extends RefCounted
## lib/domain/objective/guide/guide_advisor.dart: the guide of the tutorial:
## what it says to a player and what its halo surrounds, read from the state
## of the game alone, without playing any move. The guardians striking the
## Faille (GuideLeviathan) come first; the tutorial chapter is followed
## here, the next ones by GuideCampaign.


## The advice for `player` in `game`, null when the tutorial is off or its
## chapter is over.
static func of(game: Game, player: Player) -> GuideAdvice:
	if not ObjectiveMigration.state_of(game, player).tutorial_enabled:
		return null
	var leviathan := GuideLeviathan.of(game, player)
	if leviathan != null:
		return leviathan
	var objective := CurrentObjective.of(game, player)
	if objective == null:
		return null
	if objective.chapter != ObjectiveChapter.Value.INSTALLATION:
		return GuideCampaign.of(game, player, objective)
	var target := GuideTargets.of(player, objective.id)
	if objective.is_done(game, player):
		return GuideAdvice.new(GuideGoalMet.new(), GuideTarget.for_end_turn())
	var busy := GuideBusy.of(player, target)
	var reachable := busy.target if busy != null else target
	var advice := _raid(game, player, objective.id, reachable)
	if advice == null:
		advice = _exploration(game, player, objective.id)
	if advice == null:
		advice = _wreck(player, reachable)
	if advice == null:
		advice = busy
	return advice if advice != null else GuideAdvice.new(GuideLesson.new(objective.id), target)


## The first raid announced, while the tutorial asks to push it back with
## the harpoonists of `target`.
static func _raid(game: Game, player: Player, id: ObjectiveId.Value, target: GuideTarget) -> GuideAdvice:
	if id != ObjectiveId.Value.FIRST_RAID or not player.raid_state.is_incoming():
		return null
	return GuideRaid.of(game, player, target)


## A scout on its way, or a storm that keeps them at home.
static func _exploration(game: Game, player: Player, id: ObjectiveId.Value) -> GuideAdvice:
	if id != ObjectiveId.Value.EXPLORE:
		return null
	if not player.pending_explorations.is_empty():
		return GuideAdvice.new(GuideExploring.new(), GuideTarget.for_end_turn())
	var events := player.event_state
	if not events.is_active(RandomEventType.Value.STORM, game.turn):
		return null
	var until: int = events.active_until_turn
	return GuideAdvice.new(GuideStorm.new(until), GuideTarget.for_end_turn())


## A wreck on the map that no scout can reach yet: the halo points at the
## scouts once the barracks stand, at `target` until then. `target` is what
## the objective can use this turn.
static func _wreck(player: Player, target: GuideTarget) -> GuideAdvice:
	var events := player.event_state
	if events.wreck_position == null or events.wreck_until_turn == null:
		return null
	var until: int = events.wreck_until_turn
	if _owned(player, UnitType.Value.SCOUT) > 0:
		return null
	if Building.level_in(player.buildings, BuildingType.Value.BARRACKS) == 0:
		return GuideAdvice.new(GuideWreck.new(until, false), target)
	return GuideAdvice.new(GuideWreck.new(until, true), GuideTarget.for_unit(UnitType.Value.SCOUT))


static func _owned(player: Player, type: UnitType.Value) -> int:
	var sum := 0
	for units: Dictionary in player.units_per_level.values():
		var unit: Unit = units.get(type)
		sum += unit.count if unit != null else 0
	return sum
