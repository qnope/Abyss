class_name AttackTransitionBaseAction
extends Action
## lib/domain/action/attack_transition_base_action.dart: an assault led by an
## Abyss Admiral on the guardians of a Faille or a Cheminée nobody holds.
## Won with an admiral standing, it captures the post; the first Faille the
## human takes brings the guardians back (LeviathanResolver).

var target_x: int
var target_y: int
var level: int
var selected_units: Dictionary[UnitType.Value, int]
## Null where Dart passes none: each step then rolls a generator of its own.
var random: DartRandom
## The code of the post fought, once `execute` met it (a String), or null.
var _base_name: Variant = null


func _init(
	target_x_: int, target_y_: int, level_: int,
	selected_units_: Dictionary[UnitType.Value, int], random_: DartRandom = null,
) -> void:
	target_x = target_x_
	target_y = target_y_
	level = level_
	selected_units = selected_units_
	random = random_


func type() -> ActionType.Value:
	return ActionType.Value.ATTACK_TRANSITION_BASE


func description() -> String:
	return "Assaut base (%d, %d)" % [target_x, target_y]


func validate(game: Game, player: Player) -> ActionResult:
	return AttackTransitionBaseValidator.check(game, player, level, target_x, target_y, selected_units)


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var map: GameMap = game.levels[level]
	var base := map.cell_at(target_x, target_y).transition_base
	var player_combatants := CombatantBuilder.player_combatants_from(
		selected_units, FightMonsterHelpers.unit_boost_of(player, true)
	)
	var guardians := GuardianFactory.for_type(base.type)
	AttackTransitionBaseHelpers.remove_units_from_stock(player, level, selected_units)
	var fight_result := FightEngine.new(random).resolve(player_combatants, guardians)
	var breakdown := AttackTransitionBaseHelpers.resolve_casualties(player, level, fight_result, random)
	var sent: Dictionary[UnitType.Value, int] = {}
	for type_: UnitType.Value in selected_units:
		if selected_units[type_] > 0:
			sent[type_] = selected_units[type_]
	var victory := fight_result.is_victory()
	var admiral_alive := AttackTransitionBaseHelpers.is_admiral_alive(fight_result.final_player_combatants)
	var captured := victory and admiral_alive
	_base_name = base.name
	if captured:
		base.captured_by = player.id
		LeviathanResolver.on_capture(game, player, base, level, GridPosition.new(target_x, target_y))
	return AttackTransitionBaseResult.success(
		victory, captured, fight_result, sent,
		breakdown.survivors_intact, breakdown.wounded, breakdown.dead,
	)


func make_history_entry(_game: Game, _player: Player, result: ActionResult, turn: int) -> HistoryEntry:
	if not result is AttackTransitionBaseResult:
		return null
	var assault: AttackTransitionBaseResult = result
	if not assault.victory or assault.fight == null:
		return null
	var name: String = _base_name if _base_name != null else ""
	return CaptureEntry.new(turn, name, assault.fight, assault.captured)


func noise_made(player: Player) -> int:
	return TechEffects.of(player).muffle(NoiseRules.PER_FIGHT)
