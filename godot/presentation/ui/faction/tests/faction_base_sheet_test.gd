extends UiTestCase
## test/presentation/widgets/faction/faction_base_sheet_test.dart (and
## base_intel_report_test.dart): the sheet of a faction base, with or without
## a report of a Scout, and its two buttons.

var _faction: Faction
var _spied := 0
var _attacked := 0


func before_each() -> void:
	var game := GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 1)
	_faction = game.factions()[0]


func _intel(turn := 3) -> BaseIntel:
	return BaseIntel.new(turn, 2, 1, {UnitType.Value.GUARDIAN: 4}, {ResourceType.Value.CORAL: 120})


func _open(intel: BaseIntel = null, turn := 4, refusal: Variant = null, spy_refusal: Variant = null) -> FactionBaseSheet:
	var sheet := FactionBaseSheet.new(_faction, 2, refusal, intel, turn, spy_refusal)
	sheet.spy_requested.connect(func() -> void: _spied += 1)
	sheet.attack_requested.connect(func() -> void: _attacked += 1)
	modals().open(sheet)
	return sheet


func test_tells_who_the_faction_is_and_where_it_comes_from() -> void:
	var sheet := _open()
	assert_null(sheet.title_label, "the identity names the faction")
	assert_eq(sheet.identity.name_label.text, _faction.name())
	assert_eq(sheet.identity.name_label.get_theme_color(&"font_color"), FactionColors.of(_faction.personality))
	assert_eq(sheet.identity.origin_label.text, FactionPersonalityTexts.origin(_faction.personality))
	assert_eq(sheet.identity.emblem.icon_path, RivalEmblem.path_of(_faction.personality))
	assert_eq(sheet.headquarters_row.label.text, "Quartier général")
	assert_eq(sheet.headquarters_row.value_label.text, "2")
	var shown := texts(sheet)
	assert_true(shown.find(_faction.name()) < shown.find(sheet.identity.origin_label.text), "the origin is under the name")
	assert_no_raw_keys(sheet)


func test_without_a_report_it_says_so_and_offers_to_spy() -> void:
	var sheet := _open()
	assert_null(sheet.intel_report)
	assert_true(sheet.no_intel_label.text.begins_with("Aucun rapport"))
	assert_false(sheet.spy_button.disabled)
	assert_eq(sheet.spy_button.text, "Espionner")


func test_a_fresh_report_shows_the_army_the_rampart_and_the_stocks() -> void:
	var sheet := _open(_intel())
	assert_null(sheet.no_intel_label)
	var report := sheet.intel_report
	assert_eq(report.title_label.text, "Rapport d'éclaireur")
	assert_eq(report.freshness_label.text, "Valable encore 4 tours")
	assert_eq(report.rampart_row.label.text, "Rempart")
	assert_eq(report.rampart_row.value_label.text, "1")
	assert_eq(report.army_row.value_label.text, "4 gardiens")
	assert_eq(report.stocks_row.value_label.text, "%s 120" % ResourceTexts.display_name(ResourceType.Value.CORAL))
	assert_eq(report.freshness_label.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE_DIM)
	assert_no_raw_keys(sheet)


func test_a_stale_report_is_marked_as_such() -> void:
	var report := _open(_intel(1), 20).intel_report
	assert_true(report.freshness_label.text.contains("périmé"))
	assert_eq(report.freshness_label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_a_base_without_an_army_says_so() -> void:
	var empty := BaseIntel.new(3, 2, 0, {UnitType.Value.GUARDIAN: 0}, {})
	var report := _open(empty).intel_report
	assert_eq(report.army_row.value_label.text, "Aucun défenseur")
	assert_eq(report.stocks_row.value_label.text, "")


func test_the_report_follows_the_language() -> void:
	var sheet := _open(_intel())
	use_language("en")
	assert_eq(sheet.intel_report.title_label.text, "Scout report")
	assert_eq(sheet.intel_report.army_row.value_label.text, "4 guardians")
	assert_eq(sheet.headquarters_row.label.text, "Headquarters")
	assert_eq(sheet.attack_button.text, "Attack")
	use_language("es")
	assert_no_raw_keys(sheet)


func test_the_attack_refusal_is_told_and_switches_the_attack_off() -> void:
	var sheet := _open(null, 4, ActionFailure.Value.ATTACK_TOO_EARLY)
	assert_true(sheet.failure_label.visible)
	assert_eq(sheet.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.ATTACK_TOO_EARLY))
	assert_true(sheet.attack_button.disabled)
	assert_false(sheet.spy_button.disabled)


func test_spying_is_off_when_refused() -> void:
	var sheet := _open(null, 4, null, ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_true(sheet.spy_button.disabled)
	assert_false(sheet.attack_button.disabled)
	assert_false(sheet.failure_label.visible)


func test_spy_closes_the_sheet_and_tells_it_once() -> void:
	var sheet := _open()
	press("Espionner")
	assert_eq([_spied, _attacked], [1, 0])
	assert_true(sheet.is_closed())


func test_attack_closes_the_sheet_and_tells_it_once() -> void:
	var sheet := _open()
	press("Attaquer")
	assert_eq([_spied, _attacked], [0, 1])
	assert_true(sheet.is_closed())


func test_cancel_only_closes_it() -> void:
	var sheet := _open()
	press("Annuler")
	assert_eq([_spied, _attacked], [0, 0])
	assert_true(sheet.is_closed())
