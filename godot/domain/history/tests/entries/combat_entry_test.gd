extends TestCase
## test/domain/history/entries/combat_entry_test.dart: the line of a fight
## against a lair. Its checks of the subtitle never come: the port drops the
## field, which only kept the layout of old saves.

const SCOUT := UnitType.Value.SCOUT
const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN


func _fake_fight_result(victory: bool) -> FightResult:
	var player_combatant := Combatant.new(CombatSide.Value.PLAYER, "scout", 10, 3, 1)
	var summaries: Array[FightTurnSummary] = [FightTurnSummary.new(1, 2, 0, 5, 3, 1, 0, 7, 0)]
	return FightResult.new(
		CombatSide.Value.PLAYER if victory else CombatSide.Value.MONSTER,
		1,
		summaries,
		[player_combatant],
		[player_combatant],
		1,
		0,
	)


func test_combat_entry_victory_keeps_the_lair_and_the_outcome() -> void:
	var lair := MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 3)
	var entry := CombatEntry.new(
		5, true, 3, 4, lair, _fake_fight_result(true),
		{ResourceType.Value.ALGAE: 12, ResourceType.Value.CORAL: 8},
		{SCOUT: 2, HARPOONIST: 1}, {SCOUT: 2}, {HARPOONIST: 1}, {},
	)
	assert_eq(entry.turn, 5)
	assert_eq(entry.category, HistoryEntryCategory.Value.COMBAT)
	assert_eq(entry.lair.level(), 2)
	assert_true(entry.victory)
	assert_eq(entry.target_x, 3)
	assert_eq(entry.target_y, 4)
	assert_true(entry.lair == lair)
	assert_eq(entry.fight_result.turn_count, 1)
	assert_eq(entry.fight_result.turn_summaries.size(), 1)
	assert_eq(entry.loot[ResourceType.Value.ALGAE], 12)
	assert_eq(entry.sent[SCOUT], 2)
	assert_eq(entry.survivors_intact[SCOUT], 2)
	assert_eq(entry.wounded[HARPOONIST], 1)
	assert_true(entry.dead.is_empty())


func test_combat_entry_defeat_is_recorded_as_such() -> void:
	var entry := CombatEntry.new(
		7, false, 1, 2, MonsterLair.new(MonsterDifficulty.Value.HARD, 5),
		_fake_fight_result(false), {}, {GUARDIAN: 3}, {}, {}, {GUARDIAN: 3},
	)
	assert_eq(entry.lair.level(), 3)
	assert_false(entry.victory)
	assert_eq(entry.dead[GUARDIAN], 3)
