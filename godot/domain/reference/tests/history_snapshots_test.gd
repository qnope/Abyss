extends TestCase
## test/domain/reference/history_snapshots_test.dart. The tests of each
## class, which Dart generates in a loop, are one test that loops; the
## fields of a class are those of the port's class (ClassFields), which has
## no `title` nor `subtitle`.

var ids := PlayerIds.new("h")


## One entry of each class, by the name of the class.
func _entries() -> Dictionary[String, HistoryEntry]:
	var change := TurnResourceChange.new(ResourceType.Value.CORAL, 8, true, 10, 16, 2)
	return {
		"BuildingEntry": BuildingEntry.new(1, BuildingType.Value.BARRACKS, 2),
		"CollectEntry": CollectEntry.new(2, 3, 4, {ResourceType.Value.ORE: 5, ResourceType.Value.ALGAE: 6} as Dictionary[ResourceType.Value, int]),
		"ExploreEntry": ExploreEntry.new(3, 5, 6),
		"RecruitEntry": RecruitEntry.new(4, UnitType.Value.GUARDIAN, 7),
		"ResearchEntry": ResearchEntry.new(5, TechBranch.Value.EXPLORER, true),
		"TurnEndEntry": TurnEndEntry.new(6, [change] as Array[TurnResourceChange],
			[BuildingType.Value.LABORATORY] as Array[BuildingType.Value], {UnitType.Value.SCOUT: 1} as Dictionary[UnitType.Value, int]),
		"DescentEntry": DescentEntry.new(7, 2, 9),
		"ReinforcementEntry": ReinforcementEntry.new(8, 3, 4),
		"EventEntry": EventEntry.new(9, RandomEventType.Value.STORM, false, true),
		"CombatEntry": HistorySamples.combat_entry(true),
		"CaptureEntry": HistorySamples.capture_entry("faille-1"),
		"RaidEntry": HistorySamples.raid_entry(false, true),
		"VolcanoEntry": HistorySamples.volcano_entry(true),
		"BaseAssaultEntry": HistorySamples.base_assault_entry(true, false),
	}


func test_there_is_one_sample_per_class_of_entry() -> void:
	var entries := _entries()
	assert_eq(entries.size(), HistoryEntryCategory.Value.size())
	var categories := {}
	for e: HistoryEntry in entries.values():
		categories[e.category] = true
	assert_eq(categories.size(), HistoryEntryCategory.Value.size())


func test_an_entry_of_each_class_writes_its_fields() -> void:
	var entries := _entries()
	for name: String in entries:
		var written := HistorySnapshots.of(entries[name], ids)
		var expected: Array[String] = ClassFields.of(ClassFields.script_of(name), name)
		var keys: Array[String] = []
		keys.assign(written.keys())
		CanonicalKeys.sort(keys)
		CanonicalKeys.sort(expected)
		assert_eq(keys, expected, name)
		assert_eq(written["category"], DartEnum.name_of(HistoryEntryCategory.Value, entries[name].category), name)
		assert_ne(CanonicalWriter.write(written), "", name)


func test_an_entry_reads_as_specified() -> void:
	var entries := _entries()
	assert_eq(CanonicalWriter.write(HistorySnapshots.of(entries["CollectEntry"], ids)),
		'{"category":"collect","gains":[["ore",5],["algae",6]],"targetX":3,"targetY":4,"turn":2}')
	assert_eq(CanonicalWriter.write(HistorySnapshots.of(entries["TurnEndEntry"], ids)),
		'{"category":"turnEnd","changes":[{"afterAmount":16,"beforeAmount":10,'
		+ '"consumed":2,"produced":8,"type":"coral","wasCapped":true}],'
		+ '"deactivatedBuildings":["laboratory"],"lostUnits":[["scout",1]],"turn":6}')


func test_a_fight_keeps_its_combatants_in_order() -> void:
	var fighter := Combatant.new(CombatSide.Value.PLAYER, "harpoonist", 12, 4, 1, 7)
	assert_eq(CanonicalWriter.write(FightSnapshots.combatant().of(fighter, ids)),
		'{"atk":4,"currentHp":7,"def":1,"isBoss":false,"maxHp":12,"side":"player","typeKey":"harpoonist"}')


## Not in the Dart file: every field of an entry that holds a fight, the
## fight and its turns included.
func test_an_assault_reads_as_specified() -> void:
	var entry := HistorySamples.base_assault_entry(true, false, "faille-1", Vector2i(3, 1),
		{UnitType.Value.SCOUT: 2} as Dictionary[UnitType.Value, int], {UnitType.Value.GUARDIAN: 1} as Dictionary[UnitType.Value, int], false)
	assert_eq(CanonicalWriter.write(HistorySnapshots.of(entry, ids)),
		'{"category":"assault","dead":[["guardian",1]],"defending":false,"fightResult":{"finalMonsterCount":0,'
		+ '"finalPlayerCombatants":[],"initialMonsterCount":4,"initialPlayerCombatants":[],"turnCount":2,'
		+ '"turnSummaries":[{"attacksPlayed":2,"critCount":0,"damageDealtByMonster":5,"damageDealtByPlayer":10,'
		+ '"monsterAliveAtEnd":2,"monsterHpAtEnd":8,"playerAliveAtEnd":3,"playerHpAtEnd":12,"turnNumber":1},'
		+ '{"attacksPlayed":2,"critCount":1,"damageDealtByMonster":3,"damageDealtByPlayer":7,'
		+ '"monsterAliveAtEnd":0,"monsterHpAtEnd":0,"playerAliveAtEnd":3,"playerHpAtEnd":9,"turnNumber":2}],'
		+ '"winner":"player"},"headquartersAfter":5,"headquartersBefore":5,"loot":[],'
		+ '"lostWithPost":[["scout",2]],"opponentName":"Nacre","passageDestroyed":false,"pillaged":[],'
		+ '"postName":"faille-1","rampartAfter":1,"rampartBefore":3,"survivorsIntact":[],"turn":14,'
		+ '"units":[],"victory":true,"wounded":[]}')
