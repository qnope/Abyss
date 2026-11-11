extends CodecTestCase
## HistoryCodec, HistoryFightCodec and FightCodec: an entry of every
## category, written and read back as the same class.

const Unit := UnitType.Value
const Stock := ResourceType.Value


static func _entries() -> Array[HistoryEntry]:
	var gains: Dictionary[ResourceType.Value, int] = {Stock.CORAL: 4, Stock.ALGAE: 2}
	var lost: Dictionary[UnitType.Value, int] = {Unit.SCOUT: 1}
	var changes: Array[TurnResourceChange] = [TurnResourceChange.new(Stock.ORE, 10, true, 5, 15, 3)]
	var off: Array[BuildingType.Value] = [BuildingType.Value.ALGAE_FARM]
	return [
		BuildingEntry.new(2, BuildingType.Value.ALGAE_FARM, 3), CollectEntry.new(3, 4, 5, gains),
		ExploreEntry.new(4, 6, 7), RecruitEntry.new(5, Unit.GUARDIAN, 8),
		ResearchEntry.new(6, TechBranch.Value.MILITARY, true), ResearchEntry.new(6, TechBranch.Value.EXPLORER, false, 2),
		TurnEndEntry.new(7, changes, off, lost), DescentEntry.new(8, 2, 9), ReinforcementEntry.new(9, 3, 4),
		EventEntry.new(10, RandomEventType.Value.SURVIVORS, true, false),
		HistorySamples.combat_entry(true), HistorySamples.capture_entry("Faille"), HistorySamples.raid_entry(false, true),
		HistorySamples.volcano_entry(true), HistorySamples.base_assault_entry(
			true, false, "faille-1", null, {Unit.SCOUT: 2}, {Unit.GUARDIAN: 1}, false),
	]


func test_every_class_of_entry_comes_back_as_itself() -> void:
	var categories := {}
	var snapshots := HistorySnapshots.by_category()
	for entry: HistoryEntry in _entries():
		categories[entry.category] = true
		var read: HistoryEntry = assert_round_trip(
			snapshots[entry.category], HistoryCodec.entry, HistoryCodec.read_entry, entry)
		assert_eq(read.get_script(), entry.get_script(), str(entry.category))
	assert_eq(categories.size(), HistoryEntryCategory.Value.size())


func test_an_entry_starts_with_its_turn_and_its_category() -> void:
	var text := JSON.stringify(HistoryCodec.entry(ExploreEntry.new(4, 6, 7)), "", false)
	assert_eq(text, "{\"turn\":4,\"category\":\"explore\",\"targetX\":6,\"targetY\":7}")


func test_a_fight_keeps_its_turns_and_its_combatants() -> void:
	var fight := HistorySamples.fight(true)
	var side := CombatSide.Value.PLAYER
	fight.initial_player_combatants = [Combatant.new(side, "scout", 10, 3, 1), Combatant.new(side, "rampart", 50, 0, 9)]
	fight.final_player_combatants = [Combatant.new(side, "scout", 10, 3, 1, 4)]
	assert_round_trip(FightSnapshots.result(), FightCodec.result, FightCodec.read_result, fight)
	assert_round_trip(HistorySnapshots.resource_change(), HistoryCodec.change, HistoryCodec.read_change,
		TurnResourceChange.new(Stock.ENERGY, 1, false, 2, 3))


## Dart computes the role and the family of a combatant and saves neither:
## the constructor computes them again.
func test_a_combatant_comes_back_with_its_role_and_family_computed() -> void:
	var monster := Combatant.new(CombatSide.Value.MONSTER, "hunterL2", 30, 5, 2, 12, true)
	var written := FightCodec.combatant(monster)
	assert_false(written.has("role") or written.has("family"))
	var read := FightCodec.read_combatant(SaveReader.new(), JSON.parse_string(JSON.stringify(written)))
	assert_eq([read.role, read.family, read.current_hp, read.is_boss], [monster.role, monster.family, 12, true])


func test_an_unknown_category_is_a_problem() -> void:
	var text := JSON.stringify(HistoryCodec.entry(ExploreEntry.new(4, 6, 7)), "", false)
	assert_eq(problem_of(HistoryCodec.read_entry, text.replace("explore", "dream")),
		"category: \"dream\" is no %s" % "|".join(DartEnum.names(HistoryEntryCategory.Value)))
