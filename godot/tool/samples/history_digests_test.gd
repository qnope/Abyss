extends TestCase
## The texts of the history entries the digest tests compare.

const HARPOONIST := UnitType.Value.HARPOONIST


func test_writes_a_raid_a_volcano_and_another_entry() -> void:
	var raid := HistorySamples.raid_entry(false, true)
	raid.pillaged = {ResourceType.Value.ORE: 3, ResourceType.Value.ALGAE: 0}
	raid.dead = {HARPOONIST: 2}
	assert_eq(
		HistoryDigests.entry(raid),
		"raid 11 L medium/null/3/null/0 monster 2 4>0 r0 true |  | ore:3,algae:0 |  |  |  | harpoonist:2",
	)
	var volcano := HistorySamples.volcano_entry(true)
	volcano.defenders = {UnitType.Value.GUARDIAN: 4}
	assert_eq(
		HistoryDigests.entry(volcano), "volcano 20 V medium/null/3/null/0 player 2 4>0 k2 | guardian:4 |  |  | "
	)
	var event := EventEntry.new(9, RandomEventType.Value.COLD_CURRENT, false, true)
	assert_eq(HistoryDigests.entry(event), "event 9 coldCurrent false true")
	assert_eq(HistoryDigests.entry(HistorySamples.capture_entry("Nacre")), "capture 6")


func test_counts_the_entries_after_each_turn_then_writes_them() -> void:
	var game := GameSamples.game([GameSamples.player("human")])
	var sizes := {"human": PackedStringArray()}
	HistoryDigests.count_entries(game, sizes)
	var human := game.players["human"]
	human.add_history_entry(HistorySamples.capture_entry("Nacre"))
	HistoryDigests.count_entries(game, sizes)
	var held: PackedStringArray = sizes["human"]
	assert_eq(HistoryDigests.history(human, held), ["0 1", "capture 6"])
