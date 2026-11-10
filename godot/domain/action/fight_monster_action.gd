class_name FightMonsterAction
extends Action
## lib/domain/action/fight_monster_action.dart: sends units of `level`
## against a lair. Its one generator drives the fight, the casualties, then
## the loot of a victory, which marks the lair defeated.

var target_x: int
var target_y: int
var level: int
var selected_units: Dictionary[UnitType.Value, int]
## Null where Dart passes none: each step then rolls a generator of its own.
var random: DartRandom
var _captured_lair: MonsterLair = null


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
	return ActionType.Value.FIGHT_MONSTER


func description() -> String:
	return "Combat (%d, %d)" % [target_x, target_y]


func validate(game: Game, player: Player) -> ActionResult:
	var map: GameMap = game.levels.get(level)
	if map == null:
		return FightMonsterResult.failure(ActionFailure.Value.MAP_NOT_GENERATED)
	var cell := map.cell_at(target_x, target_y)
	if cell.content != CellContentType.Value.MONSTER_LAIR:
		return FightMonsterResult.failure(ActionFailure.Value.NO_MONSTER_HERE)
	if cell.is_collected():
		return FightMonsterResult.failure(ActionFailure.Value.LAIR_ALREADY_DEFEATED)
	if cell.lair == null:
		return FightMonsterResult.failure(ActionFailure.Value.LAIR_EMPTY)
	var total := 0
	for type_: UnitType.Value in selected_units:
		var count: int = selected_units[type_]
		if count <= 0:
			continue
		if count > Unit.count_in(player.units_on_level(level), type_):
			return FightMonsterResult.failure(ActionFailure.Value.NOT_ENOUGH_UNITS)
		total += count
	if total <= 0:
		return FightMonsterResult.failure(ActionFailure.Value.NO_UNIT_SELECTED)
	return ActionResult.success()


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var map: GameMap = game.levels[level]
	var cell := map.cell_at(target_x, target_y)
	var lair := cell.lair
	_captured_lair = lair
	var player_combatants := CombatantBuilder.player_combatants_from(
		selected_units, FightMonsterHelpers.unit_boost_of(player, true)
	)
	var monster_combatants := CombatantBuilder.monster_combatants_from(lair)
	var units := player.units_on_level(level)
	for type_: UnitType.Value in selected_units:
		units[type_].count -= selected_units[type_]
	var fight_result := FightEngine.new(random).resolve(player_combatants, monster_combatants)
	var breakdown := FightMonsterHelpers.resolve_casualties(player, level, fight_result, random)
	var sent: Dictionary[UnitType.Value, int] = {}
	for type_: UnitType.Value in selected_units:
		if selected_units[type_] > 0:
			sent[type_] = selected_units[type_]
	var loot: Dictionary[ResourceType.Value, int] = {}
	if fight_result.is_victory():
		var rolled := TechEffects.of(player).boost_loot(LootCalculator.new(random).compute(lair.difficulty))
		loot = FightMonsterHelpers.apply_loot(player, rolled)
		map.set_cell(target_x, target_y, cell.copy_with({"collected_by": player.id}))
	return FightMonsterResult.success(
		fight_result.is_victory(), fight_result, loot, sent,
		breakdown.survivors_intact, breakdown.wounded, breakdown.dead,
	)


func make_history_entry(_game: Game, _player: Player, result: ActionResult, turn: int) -> HistoryEntry:
	if not result is FightMonsterResult or not result.is_success:
		return null
	var fought: FightMonsterResult = result
	return FightMonsterHelpers.build_combat_entry(turn, target_x, target_y, _captured_lair, fought)


func noise_made(player: Player) -> int:
	return TechEffects.of(player).muffle(NoiseRules.PER_FIGHT)
