extends TestCase
## test/domain/action/make_history_entry_test.dart, the group
## 'FightMonsterAction.makeHistoryEntry'.

const HARPOONIST := UnitType.Value.HARPOONIST


func _scenario() -> Game:
	return ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 20})


func _action() -> FightMonsterAction:
	return FightMonsterAction.new(1, 1, 1, {HARPOONIST: 20}, DartRandom.new(0))


func test_fight_monster_action_make_history_entry_returns_combat_entry_mirroring_the_fight_monster_result() -> void:
	var game := _scenario()
	var player := game.human_player()
	var action := _action()
	var result := action.execute(game, player)
	assert_true(result is FightMonsterResult)
	var fight: FightMonsterResult = result
	assert_true(fight.is_success)
	var combat: CombatEntry = action.make_history_entry(game, player, result, 17)
	assert_eq([combat.turn, combat.category, combat.victory], [17, HistoryEntryCategory.Value.COMBAT, fight.victory])
	assert_eq([combat.target_x, combat.target_y], [1, 1])
	assert_eq([combat.lair.difficulty, combat.lair.unit_count], [MonsterDifficulty.Value.EASY, 1])
	assert_true(combat.fight_result == fight.fight)
	assert_eq([combat.loot, combat.sent], [fight.loot, fight.sent])
	assert_eq([combat.survivors_intact, combat.wounded, combat.dead], [fight.survivors_intact, fight.wounded, fight.dead])


func test_fight_monster_action_make_history_entry_returns_null_when_fight_has_not_been_executed() -> void:
	var game := _scenario()
	# No execute: captured lair is still null, and the result we fabricate is
	# a failure. Expect null.
	var result := FightMonsterResult.failure(ActionFailure.Value.LAIR_EMPTY)
	assert_null(_action().make_history_entry(game, game.human_player(), result, 1))


## Not in the Dart file: a plain result is no fight, and a fight is noise.
func test_a_result_of_another_kind_keeps_no_entry_and_a_fight_is_noise() -> void:
	var game := _scenario()
	var action := _action()
	action.execute(game, game.human_player())
	assert_null(action.make_history_entry(game, game.human_player(), ActionResult.success(), 1))
	assert_eq(action.noise_made(game.human_player()), NoiseRules.PER_FIGHT)
	assert_eq([action.type(), action.description()], [ActionType.Value.FIGHT_MONSTER, "Combat (1, 1)"])
