extends TestCase
## Not in the Dart files: lib/domain/raid/raid_report.dart has no test of
## its own, raid_resolver_test.dart checks the type of the entry it gives.
## `toEntry` hands each field to the RaidEntry of the same name.

const HARPOONIST := UnitType.Value.HARPOONIST


func test_to_entry_replays_the_fight_and_the_fate_of_the_defenders() -> void:
	var wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 5)
	var fight := FightResult.new(CombatSide.Value.MONSTER, 4, [], [], [], 5, 3)
	var defenders: Dictionary[UnitType.Value, int] = {HARPOONIST: 4}
	var intact: Dictionary[UnitType.Value, int] = {HARPOONIST: 1}
	var wounded: Dictionary[UnitType.Value, int] = {HARPOONIST: 2}
	var dead: Dictionary[UnitType.Value, int] = {HARPOONIST: 3}
	var loot: Dictionary[ResourceType.Value, int] = {ResourceType.Value.ALGAE: 6}
	var pillaged: Dictionary[ResourceType.Value, int] = {ResourceType.Value.ORE: 7}
	for surprise: bool in [false, true]:
		var report := RaidReport.new(
			12, false, wave, fight, 2, defenders, intact, wounded, dead, loot, pillaged, surprise
		)
		var e := report.to_entry()
		assert_eq([e.turn, e.category, e.victory, e.wave, e.fight_result], [12, HistoryEntryCategory.Value.RAID, false, wave, fight])
		assert_eq([e.loot, e.pillaged, e.defenders], [loot, pillaged, defenders])
		assert_eq([e.survivors_intact, e.wounded, e.dead], [intact, wounded, dead])
		assert_eq([e.rampart_level, e.surprise], [2, surprise])
