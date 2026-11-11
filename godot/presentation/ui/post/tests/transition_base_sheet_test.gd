extends UiTestCase
## test/presentation/widgets/map/transition_base_sheet_test.dart, _captured_test,
## _l10n_test: the sheet of a Faille or a Cheminée, guarded or held.

const Faille := TransitionBaseType.Value.FAILLE
const Cheminee := TransitionBaseType.Value.CHEMINEE
const Harpoonist := UnitType.Value.HARPOONIST

var _assaults := 0
var _descents := 0


func _sheet(kind: TransitionBaseType.Value, held: bool, plan: Control = null) -> TransitionBaseSheet:
	var war := PostWar.new(kind, 7, held)
	if not held:
		war.post.captured_by = null
	var sheet := TransitionBaseSheet.new(war.game, war.post, plan)
	sheet.assault_requested.connect(func() -> void: _assaults += 1)
	sheet.descend_requested.connect(func() -> void: _descents += 1)
	modals().open(sheet)
	return sheet


func _row(sheet: TransitionBaseSheet, label: String) -> String:
	for row: SheetInfoRow in find_type("SheetInfoRow", sheet):
		if row.label.text == label:
			return row.value_label.text
	return "(no row %s)" % label


func test_a_guarded_faille_shows_its_difficulty_income_and_guardians() -> void:
	var sheet := _sheet(Faille, false)
	assert_true(sheet.section is TransitionBaseUncapturedSection)
	assert_eq(sheet.title_label.text, TransitionBaseNameTexts.label(sheet.base.name))
	assert_eq(sheet.kind_label.text, "Faille Abyssale")
	assert_eq(_row(sheet, "Difficulté"), "4/5")
	assert_eq(_row(sheet, "Revenu une fois capturée"), "+2 perles par tour")
	assert_not_null(find_text("Neutre — Gardiens présents", sheet))
	assert_no_raw_keys(sheet)


func test_a_cheminee_is_harder_and_pays_more() -> void:
	var sheet := _sheet(Cheminee, false)
	assert_eq(sheet.kind_label.text, "Cheminée du Noyau")
	assert_eq(_row(sheet, "Difficulté"), "5/5")
	assert_eq(_row(sheet, "Revenu une fois capturée"), "+3 perles par tour")


func test_the_picture_is_lit_by_who_holds_the_post() -> void:
	var guarded := find_type("Portrait", _sheet(Faille, false))[0] as Portrait
	assert_eq(guarded.initials_label.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE_DIM)
	modals().close_top()
	var held := find_type("Portrait", _sheet(Faille, true))[0] as Portrait
	assert_eq(held.initials_label.get_theme_color(&"font_color"), AbyssColors.BIOLUM_CYAN)


func test_the_plan_comes_before_the_assault_button() -> void:
	var plan := Label.new()
	plan.text = "Plan"
	var sheet := _sheet(Faille, false, plan)
	var order := texts(sheet)
	assert_true(order.find("Plan") < order.find("Assaut"))


func test_assaulting_closes_the_sheet_and_tells_it_once() -> void:
	var sheet := _sheet(Faille, false)
	press("Assaut")
	assert_eq(_assaults, 1)
	assert_true(sheet.is_closed())
	assert_eq(_descents, 0)


func test_a_held_post_tells_its_income_and_its_defenders() -> void:
	var war := PostWar.new(Faille, 7, true)
	war.put(war.human(), 2, {Harpoonist: 3})
	var sheet := TransitionBaseSheet.new(war.game, war.post)
	modals().open(sheet)
	assert_true(sheet.section is TransitionBaseCapturedSection)
	assert_not_null(find_text("Capturée", sheet))
	assert_not_null(find_text("+2 perles par tour", sheet))
	assert_not_null(find_text("Défenseurs au Niveau 2", sheet))
	assert_not_null(find_text("Si la Faille tombe", sheet), "the defence is shown")
	assert_no_raw_keys(sheet)


func test_a_held_cheminee_counts_the_units_of_level_3() -> void:
	var war := PostWar.new(Cheminee, 7, true)
	war.put(war.human(), 3, {Harpoonist: 4})
	modals().open(TransitionBaseSheet.new(war.game, war.post))
	assert_not_null(find_text("Défenseurs au Niveau 3"))
	assert_not_null(find_text("Si la Cheminée tombe"))


func test_nobody_defending_the_post_is_said() -> void:
	var sheet := _sheet(Faille, true)
	assert_not_null(find_text("Aucune unité. Si une faction attaque, le poste tombe et son module est détruit.", sheet))


func test_going_down_asks_for_the_passage_building() -> void:
	var war := PostWar.new(Faille, 7, true)
	war.owner().buildings.erase(BuildingType.Value.DESCENT_MODULE)
	var sheet := TransitionBaseSheet.new(war.game, war.post)
	modals().open(sheet)
	var captured := sheet.section as TransitionBaseCapturedSection
	assert_true(captured.descend_button.disabled)
	assert_true(captured.warning_label.visible)
	assert_eq(captured.warning_label.text, "Bâtiment requis pour envoyer des unités : Module de Descente")


func test_going_down_closes_the_sheet_and_tells_it_once() -> void:
	var sheet := _sheet(Faille, true)
	var captured := sheet.section as TransitionBaseCapturedSection
	assert_false(captured.warning_label.visible)
	assert_eq(captured.descend_button.text, "Envoyer des unités au Niveau 2")
	press(captured.descend_button)
	assert_eq(_descents, 1)
	assert_true(sheet.is_closed())
	assert_eq(_assaults, 0)


func test_the_sheet_speaks_english_and_spanish() -> void:
	var sheet := _sheet(Faille, true)
	use_language("en")
	assert_not_null(find_text("Captured", sheet))
	assert_not_null(find_text("If the Rift falls", sheet))
	assert_no_raw_keys(sheet)
	use_language("es")
	assert_not_null(find_text("Capturada", sheet))
	assert_no_raw_keys(sheet)
	modals().close_top()
	var guarded := _sheet(Cheminee, false)
	use_language("en")
	assert_not_null(find_text("Assault", guarded))
	assert_no_raw_keys(guarded)
