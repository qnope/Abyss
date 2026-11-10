extends TestCase
## test/domain/fight/combat_side_test.dart: the two sides of a fight.


func test_combat_side_opponent_player_opponent_is_monster() -> void:
	assert_eq(CombatSide.opponent(CombatSide.Value.PLAYER), CombatSide.Value.MONSTER)


func test_combat_side_opponent_monster_opponent_is_player() -> void:
	assert_eq(CombatSide.opponent(CombatSide.Value.MONSTER), CombatSide.Value.PLAYER)


## Not in the Dart file: the names and the order the snapshots write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(CombatSide.Value), PackedStringArray(["player", "monster"]))
