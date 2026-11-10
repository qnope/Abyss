class_name AttackBaseValidator
extends RefCounted
## lib/domain/action/attack_base_validator.dart: the rules that say whether
## a player may attack the base of another. Each failure is an
## ActionFailure.Value, or null when there is none.


## Why the attack on `target_id` with `army` is refused, null if it is not.
static func check(
	game: Game, player: Player, target_id: String, army: Dictionary[UnitType.Value, int]
) -> Variant:
	var refused: Variant = refusal(game, player, target_id)
	return refused if refused != null else army_failure(player, army)


## Why `player` may not attack `target_id` at all, whatever the army: the
## part of `check` a screen can tell before an army is chosen.
static func refusal(game: Game, player: Player, target_id: String) -> Variant:
	var target: Player = game.players.get(target_id)
	if target_id == player.id:
		return ActionFailure.Value.CANNOT_ATTACK_SELF
	if target == null:
		return ActionFailure.Value.NO_SUCH_PLAYER
	if target.has_fallen():
		return ActionFailure.Value.PLAYER_FALLEN
	if is_protected(game, player) or is_protected(game, target):
		return ActionFailure.Value.ATTACK_TOO_EARLY
	if player.id == game.human_player_id and not _has_seen(player, target):
		return ActionFailure.Value.BASE_NOT_REVEALED
	return already_hit(game, player, target)


## A player strikes the same opponent once a turn at most, whatever it hits
## (its base, a post or the kernel it holds).
static func already_hit(game: Game, player: Player, target: Player) -> Variant:
	var again := player.history_entries.any(func(e: HistoryEntry) -> bool:
		if not e is BaseAssaultEntry:
			return false
		var assault: BaseAssaultEntry = e
		return not assault.defending and assault.turn == game.turn and assault.opponent_name == target.name
	)
	return ActionFailure.Value.ALREADY_ATTACKED_THIS_TURN if again else null


## Whether `player` is too new for a base war: no one attacks before the
## turn of the first raid, nor while the first chapter of the objectives,
## the tutorial, is unfinished for a player it guides.
static func is_protected(game: Game, player: Player) -> bool:
	if game.turn < NoiseRules.FIRST_RAID_TURN:
		return true
	var state := ObjectiveMigration.state_of(game, player)
	return state.tutorial_enabled and not InstallationObjectives.installation_objectives().all(
		func(o: Objective) -> bool: return state.is_completed(o.id)
	)


static func _has_seen(player: Player, target: Player) -> bool:
	return player.revealed_cells_set_on_level(1).has(Vector2i(target.base_x, target.base_y))


## Why `army` cannot leave the units of `level` of `player` (the base level
## by default), null if it can.
static func army_failure(player: Player, army: Dictionary[UnitType.Value, int], level := 1) -> Variant:
	var total := 0
	for type: UnitType.Value in army:
		var count: int = army[type]
		if count <= 0:
			continue
		if count > Unit.count_in(player.units_on_level(level), type):
			return ActionFailure.Value.NOT_ENOUGH_UNITS
		total += count
	return null if total > 0 else ActionFailure.Value.NO_UNIT_SELECTED
