extends TestCase
## test/domain/fight/fight_result_test.dart: how a fight ended.
## fight_result_hive_test.dart never comes: a Hive round-trip, and the saves
## of the port are JSON, in data/.

const PLAYER := CombatSide.Value.PLAYER
const MONSTER := CombatSide.Value.MONSTER

var _initial_player := Combatant.new(PLAYER, "scout", 12, 3, 1)
var _final_player := Combatant.new(PLAYER, "scout", 12, 3, 1, 5)
var _summary := FightTurnSummary.new(1, 2, 0, 5, 3, 1, 0, 5, 0)


func _ended(winner: CombatSide.Value, final_monster_count: int) -> FightResult:
	return FightResult.new(winner, 2, [], [], [], 1, final_monster_count)


func test_fight_result_constructor_stores_every_field_correctly() -> void:
	var result := FightResult.new(
		PLAYER, 4, [_summary], [_initial_player], [_final_player], 3, 0
	)

	assert_eq(result.winner, PLAYER)
	assert_eq(result.turn_count, 4)
	assert_eq(result.turn_summaries.size(), 1)
	assert_eq(result.turn_summaries[0], _summary)
	assert_eq(result.initial_player_combatants, [_initial_player])
	assert_eq(result.final_player_combatants, [_final_player])
	assert_eq(result.initial_monster_count, 3)
	assert_eq(result.final_monster_count, 0)


func test_fight_result_is_victory_is_true_when_winner_is_player() -> void:
	assert_true(_ended(PLAYER, 0).is_victory())


func test_fight_result_is_victory_is_false_when_winner_is_monster() -> void:
	assert_false(_ended(MONSTER, 1).is_victory())
