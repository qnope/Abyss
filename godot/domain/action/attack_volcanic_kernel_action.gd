class_name AttackVolcanicKernelAction
extends Action
## lib/domain/action/attack_volcanic_kernel_action.dart: an assault led by
## an Abyss Admiral on the guardians of the volcanic kernel nobody holds.
## Won with an admiral standing, it captures the kernel.

var target_x: int
var target_y: int
var level: int
var selected_units: Dictionary[UnitType.Value, int]
## Null where Dart passes none: each step then rolls a generator of its own.
var random: DartRandom


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
	return ActionType.Value.ATTACK_VOLCANIC_KERNEL


func description() -> String:
	return "Assaut Noyau Volcanique"


func validate(game: Game, player: Player) -> ActionResult:
	var map: GameMap = game.levels.get(level)
	if map == null:
		return AttackVolcanicKernelResult.failure(ActionFailure.Value.MAP_NOT_GENERATED)
	var cell := map.cell_at(target_x, target_y)
	if cell.content != CellContentType.Value.VOLCANIC_KERNEL:
		return AttackVolcanicKernelResult.failure(ActionFailure.Value.NO_VOLCANIC_KERNEL_HERE)
	if cell.is_collected():
		return AttackVolcanicKernelResult.failure(ActionFailure.Value.KERNEL_ALREADY_CAPTURED)
	var unit_err := AttackVolcanicKernelHelpers.validate_units(player, level, selected_units)
	if unit_err != null:
		return unit_err
	return ActionResult.success()


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var player_combatants := CombatantBuilder.player_combatants_from(
		selected_units, FightMonsterHelpers.unit_boost_of(player, true)
	)
	var guardians := GuardianFactory.for_volcanic_kernel()
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
	if captured:
		var map: GameMap = game.levels[level]
		var cell := map.cell_at(target_x, target_y)
		map.set_cell(target_x, target_y, cell.copy_with({"collected_by": player.id}))
	return AttackVolcanicKernelResult.success(
		victory, captured, fight_result, sent,
		breakdown.survivors_intact, breakdown.wounded, breakdown.dead,
	)


func make_history_entry(_game: Game, _player: Player, result: ActionResult, turn: int) -> HistoryEntry:
	if not result is AttackVolcanicKernelResult:
		return null
	var assault: AttackVolcanicKernelResult = result
	if not assault.victory or assault.fight == null:
		return null
	return CaptureEntry.new(turn, CaptureEntry.VOLCANIC_KERNEL, assault.fight, assault.captured)


func noise_made(player: Player) -> int:
	return TechEffects.of(player).muffle(NoiseRules.PER_FIGHT)
