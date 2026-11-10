extends TestCase
## Not in the Dart files: PredatorsEffect.strike, which
## test/domain/event/event_resolver_predators_test.dart checks through
## ChooseEventAction (the action module). The same checks, the predators
## faced through the effect itself as that action does.

const SEED := 4
const HARPOONIST := UnitType.Value.HARPOONIST

var _garrison: Dictionary[UnitType.Value, int] = {HARPOONIST: 30}


## `_face`: faces the predators of `player` during turn 12 and strikes.
func _face(player: Player, lost_in_a_row := 0) -> RaidReport:
	player.raid_state.lost_in_a_row = lost_in_a_row
	PredatorsEffect.new().apply(EventSamples.event_game(player, 12), player, true, 12)
	return PredatorsEffect.strike(player, 12, DartRandom.new(SEED))


## `_raidOf`: the raid `twin` would fight against the same wave and dice.
func _raid_of(twin: Player) -> RaidReport:
	return RaidBattle.fight(twin, EventSamples.predator_test_wave(), 12, DartRandom.new(SEED))


func test_faced_they_strike_at_the_end_of_the_turn_like_a_raid() -> void:
	var report := _face(EventSamples.threatened_player(_garrison, 3))
	var raid := _raid_of(RaidSamples.raid_player(_garrison, 3))
	assert_eq([report.turn, report.surprise, report.defenders, report.rampart_level], [12, true, _garrison, 3])
	assert_eq(report.victory, raid.victory)
	assert_eq(report.fight.turn_summaries.size(), raid.fight.turn_summaries.size())
	assert_eq(report.dead, raid.dead)


func test_a_victory_brings_half_the_loot_of_a_raid_and_is_recorded() -> void:
	var player := EventSamples.threatened_player(_garrison)
	var report := _face(player)
	var raid := _raid_of(RaidSamples.raid_player(_garrison))
	assert_true(report.victory)
	assert_false(raid.loot.is_empty())
	var halves: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in raid.loot:
		halves[type] = DartMath.trunc_div(raid.loot[type], 2)
	assert_eq(report.loot, halves)
	assert_eq(player.resources[ResourceType.Value.CORAL].amount, 1000 + report.loot[ResourceType.Value.CORAL])
	assert_eq([player.raid_state.raids_repelled, player.raid_state.raids_lost], [0, 0])
	assert_eq(player.history_entries.size(), 1)
	var entry: RaidEntry = player.history_entries[0]
	assert_eq([entry.surprise, entry.turn, entry.loot, entry.fight_result], [true, 12, report.loot, report.fight])
	assert_null(player.event_state.predator_wave)
	assert_null(player.event_state.predators_turn)


func test_a_defeat_pillages_like_a_raid_but_is_not_a_lost_raid() -> void:
	var player := EventSamples.threatened_player()
	var report := _face(player, 2)
	var raid := _raid_of(RaidSamples.raid_player())
	assert_false(report.victory)
	assert_eq([report.pillaged, report.loot], [raid.pillaged, {}])
	assert_eq(player.resources[ResourceType.Value.CORAL].amount, 700)
	assert_eq([player.raid_state.lost_in_a_row, player.raid_state.raids_lost], [2, 0])
	assert_null(DefeatChecker.check(Game.single_player(player)))


func test_nothing_strikes_before_the_turn_faced_nor_without_a_wave() -> void:
	var player := EventSamples.threatened_player()
	player.event_state.predators_turn = 13
	assert_null(PredatorsEffect.strike(player, 12, DartRandom.new(SEED)))
	assert_not_null(player.event_state.predator_wave)
	player.event_state.predator_wave = null
	assert_null(PredatorsEffect.strike(player, 13, DartRandom.new(SEED)))
	assert_null(player.event_state.predators_turn)
	assert_null(PredatorsEffect.strike(player, 14, DartRandom.new(SEED)))
	assert_true(player.history_entries.is_empty())
