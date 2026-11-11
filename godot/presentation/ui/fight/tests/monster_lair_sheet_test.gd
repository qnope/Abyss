extends UiTestCase
## test/presentation/widgets/map/monster_lair_sheet_test.dart: what a touch on
## a lair tells of the monsters, and the button that prepares the fight.

const Family := MonsterFamily.Value
const Difficulty := MonsterDifficulty.Value

var _prepared := 0
var _closed: Array[Variant] = []


func _open(lair: MonsterLair) -> MonsterLairSheet:
	var sheet := MonsterLairSheet.new(lair, 1, 2)
	sheet.prepare_requested.connect(func() -> void: _prepared += 1)
	sheet.closed.connect(_closed.append)
	modals().open(sheet)
	return sheet


func _row(sheet: MonsterLairSheet, label: String) -> String:
	for row: SheetInfoRow in find_type("SheetInfoRow", sheet):
		if row.label.text == label:
			return row.value_label.text
	return "(no row %s)" % label


func test_the_sheet_tells_the_difficulty_the_level_the_count_and_the_stats() -> void:
	var sheet := _open(MonsterLair.new(Difficulty.MEDIUM, 4))
	assert_eq(sheet.title_label.text, "Rôdeurs (1, 2)")
	assert_eq(_row(sheet, "Difficulté"), "Moyen")
	assert_eq(_row(sheet, "Niveau"), "2")
	assert_eq(_row(sheet, "Unités"), "4 monstres")
	assert_eq(_row(sheet, "PV / ATK / DEF"), "20 / 5 / 2")
	assert_false(sheet.traits.visible, "the generic monsters have no rule")
	assert_no_raw_keys(sheet)


func test_a_family_adds_its_rule_and_its_weakness() -> void:
	var sheet := _open(MonsterLair.new(Difficulty.MEDIUM, 50, Family.HUNTER))
	assert_eq(sheet.title_label.text, "Chasseurs (1, 2)")
	assert_eq(_row(sheet, "Unités"), "50 Calmars-chasseurs")
	assert_eq(_row(sheet, "PV / ATK / DEF"), "16 / 10 / 2")
	assert_true(sheet.traits.visible)
	assert_true(sheet.traits.rule_label.text.contains("Traque"))
	assert_not_null(find_text("Faible contre : Gardiens", sheet))


func test_a_hard_lair_has_the_stats_of_its_level() -> void:
	var sheet := _open(MonsterLair.new(Difficulty.HARD, 6))
	assert_eq(_row(sheet, "Difficulté"), "Difficile")
	assert_eq(_row(sheet, "PV / ATK / DEF"), "35 / 8 / 3")


func test_the_picture_is_the_initials_of_the_family() -> void:
	var sheet := _open(MonsterLair.new(Difficulty.EASY, 2, Family.SWARM))
	var portrait := find_type("Portrait", sheet)[0] as Portrait
	assert_eq(portrait.initials_label.text, Portrait.initials(MonsterFamilyTexts.label(Family.SWARM)))


func test_preparing_the_fight_closes_the_sheet_and_tells_it_once() -> void:
	var sheet := _open(MonsterLair.new(Difficulty.EASY, 2))
	press("Préparer le combat")
	assert_eq(_prepared, 1)
	assert_true(sheet.is_closed())
	assert_null(current_modal())


func test_cancelling_closes_the_sheet_without_preparing() -> void:
	var sheet := _open(MonsterLair.new(Difficulty.EASY, 2))
	press("Annuler")
	assert_eq(_prepared, 0)
	assert_true(sheet.is_closed())
	assert_eq(_closed.size(), 1)


func test_the_sheet_follows_the_language() -> void:
	var sheet := _open(MonsterLair.new(Difficulty.MEDIUM, 4, Family.HUNTER))
	use_language("en")
	assert_eq(sheet.title_label.text, "%s (1, 2)" % MonsterFamilyTexts.label(Family.HUNTER))
	assert_eq(_row(sheet, "Difficulty"), "Medium")
	assert_eq(sheet.prepare_button.text, text(&"fightPrepare"))
	assert_eq(sheet.cancel_button.text, "Cancel")
	assert_no_raw_keys(sheet)
