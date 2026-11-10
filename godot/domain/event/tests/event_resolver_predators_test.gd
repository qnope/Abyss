extends TestCase
## test/domain/event/event_resolver_predators_test.dart: the predators
## faced during a turn strike at its end, like a raid.

const SEED := 4
const CORAL := ResourceType.Value.CORAL

var _garrison: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 30}


## Faces the predators of `player` during turn 12 and ends that turn.
func _face(player: Player, lost_in_a_row := 0) -> EventTurnOutcome:
	player.raid_state.lost_in_a_row = lost_in_a_row
	var game := EventSamples.event_game(player, 12)
	ChooseEventAction.new(true).execute(game, player)
	return EventResolver.resolve(game, player, 12, DartRandom.new(SEED))


## The raid `twin` would fight against the same wave with the same dice.
func _raid_of(twin: Player) -> RaidReport:
	return RaidBattle.fight(twin, EventSamples.predator_test_wave(), 12, DartRandom.new(SEED))


func _expect_raids_untouched(player: Player, lost_in_a_row := 0) -> void:
	var state := player.raid_state
	assert_eq([state.lost_in_a_row, state.raids_lost, state.raids_repelled], [lost_in_a_row, 0, 0])


func test_faced_they_strike_at_the_end_of_the_turn_like_a_raid() -> void:
	var player := EventSamples.threatened_player(_garrison, 3)
	var report := _face(player).predators
	var raid := _raid_of(RaidSamples.raid_player(_garrison, 3))
	assert_eq([report.turn, report.surprise, report.defenders, report.rampart_level], [12, true, _garrison, 3])
	assert_eq(report.victory, raid.victory)
	assert_eq(report.fight.turn_summaries.size(), raid.fight.turn_summaries.size())
	assert_eq(report.dead, raid.dead)


func test_a_victory_brings_half_the_loot_of_a_raid() -> void:
	var player := EventSamples.threatened_player(_garrison)
	var report := _face(player).predators
	var raid := _raid_of(RaidSamples.raid_player(_garrison))
	assert_true(report.victory)
	assert_false(raid.loot.is_empty())
	var half: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in raid.loot:
		half[type] = DartMath.trunc_div(raid.loot[type], 2)
	assert_eq(report.loot, half)
	assert_eq(report.loot.keys(), half.keys())
	assert_eq(player.resources[CORAL].amount, 1000 + report.loot[CORAL])
	_expect_raids_untouched(player)


func test_a_defeat_pillages_like_a_raid_but_is_not_a_lost_raid() -> void:
	var player := EventSamples.threatened_player()
	var report := _face(player, 2).predators
	var raid := _raid_of(RaidSamples.raid_player())
	assert_false(report.victory)
	assert_eq(report.pillaged, raid.pillaged)
	assert_true(report.loot.is_empty())
	assert_eq(player.resources[CORAL].amount, 700)
	_expect_raids_untouched(player, 2)
	assert_null(DefeatChecker.check(Game.single_player(player)))


func test_the_fight_is_recorded_to_be_replayed_and_the_wave_forgotten() -> void:
	var player := EventSamples.threatened_player(_garrison)
	var report := _face(player).predators
	var raids := player.history_entries.filter(func(e: HistoryEntry) -> bool: return e is RaidEntry)
	assert_eq(raids.size(), 1)
	var entry: RaidEntry = raids[0]
	assert_eq([entry.surprise, entry.turn, entry.loot], [true, 12, report.loot])
	assert_true(entry.fight_result == report.fight)
	assert_null(player.event_state.predator_wave)
	assert_null(player.event_state.predators_turn)
	var next := EventResolver.resolve(EventSamples.event_game(player, 13), player, 13, DartRandom.new(1))
	assert_null(next.predators)
