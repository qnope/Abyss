extends UiTestCase
## The turns of a fight and the group of monsters it is fought against
## (test/presentation/widgets/fight/).

const Family := MonsterFamily.Value


func _list() -> FightTurnList:
	return mount(FightTurnList.new(HistorySamples.fight(true).turn_summaries)) as FightTurnList


func test_the_list_has_a_tile_per_turn() -> void:
	var list := _list()
	assert_eq(list.tiles.size(), 2)
	assert_eq(list.tiles[0].title_label.text, "Tour 1")
	assert_eq(list.tiles[1].title_label.text, "Tour 2")
	assert_no_raw_keys()


func test_a_tile_tells_each_side_of_the_turn() -> void:
	var tile := _list().tiles[0]
	var lines: Array[String] = []
	for label in tile.stat_labels:
		lines.append(label.text)
	assert_eq(lines, [
		"Alliés vivants : 3", "PV alliés : 12", "Dégâts infligés : 10",
		"Ennemis vivants : 2", "PV ennemis : 8", "Dégâts subis : 5",
	] as Array[String])


func test_a_tile_shows_the_critical_hits_only_when_there_were_some() -> void:
	var list := _list()
	assert_null(list.tiles[0].crit_label)
	assert_eq(list.tiles[1].crit_label.text, "Coups critiques : 1")


func test_an_empty_fight_has_no_tile() -> void:
	var empty: Array[FightTurnSummary] = []
	assert_eq((mount(FightTurnList.new(empty)) as FightTurnList).tiles.size(), 0)


func test_a_tile_follows_the_language() -> void:
	var tile := _list().tiles[1]
	use_language("en")
	assert_eq(tile.title_label.text, text(&"commonTurn", {"turn": 2}))
	assert_eq(tile.crit_label.text, text(&"fightCriticalHits", {"count": 1}))


func test_the_preview_names_the_group_its_level_and_its_stats() -> void:
	var lair := MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 12, Family.ARMOURED)
	var preview := mount(MonsterPreview.new(lair)) as MonsterPreview
	assert_eq(preview.title_label.text, "Carapaces · Moyen")
	assert_eq(preview.level_label.text, "Niveau 2")
	assert_eq(preview.count_label.text, "12 Isopodes cuirassés")
	var stats := MonsterUnitStats.of(Family.ARMOURED, 2)
	assert_eq(preview.chips[0].text, "PV: %d" % stats.hp)
	assert_eq(preview.chips[1].text, "ATK: %d" % stats.atk)
	assert_eq(preview.chips[2].text, "DEF: %d" % stats.def)
	assert_no_raw_keys()


func test_the_preview_adds_the_rule_of_the_family_and_what_answers_it() -> void:
	var preview := mount(MonsterPreview.new(MonsterLair.new(MonsterDifficulty.Value.EASY, 40, Family.SWARM))) as MonsterPreview
	assert_true(preview.traits.visible)
	assert_eq(preview.traits.rule_label.text, MonsterFamilyTexts.rule(Family.SWARM))
	assert_eq(preview.traits.weakness_label.text, "Faible contre : Harponneurs")


func test_the_generic_monsters_have_no_traits() -> void:
	var preview := mount(MonsterPreview.new(MonsterLair.new(MonsterDifficulty.Value.HARD, 5))) as MonsterPreview
	assert_false(preview.traits.visible)
	assert_eq(preview.title_label.text, "Rôdeurs · Difficile")
	assert_eq(preview.level_label.text, "Niveau 3")


func test_the_preview_follows_the_language() -> void:
	var preview := mount(MonsterPreview.new(MonsterLair.new(MonsterDifficulty.Value.EASY, 40, Family.SWARM))) as MonsterPreview
	use_language("en")
	assert_eq(preview.title_label.text, "%s · Easy" % MonsterFamilyTexts.label(Family.SWARM))
	assert_eq(preview.chips[0].text, "HP: %d" % preview.stats.hp)
	assert_eq(preview.portrait.initials_label.text, Portrait.initials(MonsterFamilyTexts.label(Family.SWARM)))
