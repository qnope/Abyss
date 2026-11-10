extends TestCase
## test/domain/raid/raid_battle_test.dart: a raid fought by every unit on the
## base, backed by the Citadel rampart.

const HARPOONIST := UnitType.Value.HARPOONIST
const CORAL := ResourceType.Value.CORAL
const PEARL := ResourceType.Value.PEARL

var _wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 5)


func test_an_empty_base_loses_and_is_pillaged_pearls_aside() -> void:
	var player := RaidSamples.raid_player()
	var report := RaidBattle.fight(player, _wave, 10, DartRandom.new(1))
	assert_false(report.victory)
	assert_eq(report.defenders, {})
	assert_eq(report.pillaged[CORAL], 300)
	assert_false(report.pillaged.has(PEARL))
	assert_eq(player.resources[CORAL].amount, 700)
	assert_eq(player.resources[PEARL].amount, 1000)


func test_a_strong_garrison_wins_keeps_its_units_and_earns_loot() -> void:
	var player := RaidSamples.raid_player({HARPOONIST: 30}, 0, 1)
	var report := RaidBattle.fight(player, _wave, 10, DartRandom.new(1))
	assert_true(report.victory)
	assert_eq(report.defenders, {HARPOONIST: 30})
	assert_eq(report.pillaged, {})
	# Two turns of the headquarters' 15 coral.
	assert_eq(report.loot[CORAL], 30)
	var dead: int = report.dead.get(HARPOONIST, 0)
	assert_eq(RaidSamples.units_on_base(player), 30 - dead)


func test_the_citadel_rampart_fights_alongside_the_defenders() -> void:
	var player := RaidSamples.raid_player({}, 5)
	var report := RaidBattle.fight(player, _wave, 10, DartRandom.new(1))
	assert_eq(report.rampart_level, 5)
	assert_eq(report.fight.initial_player_combatants.size(), 1)
	assert_eq(report.fight.initial_player_combatants[0].max_hp, 200)


func test_units_on_deeper_levels_do_not_defend() -> void:
	var player := RaidSamples.raid_player()
	var deeper: Dictionary[UnitType.Value, Unit] = {HARPOONIST: Unit.new(HARPOONIST, 10)}
	player.units_per_level[2] = deeper
	assert_eq(RaidBattle.defenders_of(player), {})
