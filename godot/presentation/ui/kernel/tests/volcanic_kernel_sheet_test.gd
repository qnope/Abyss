extends UiTestCase
## test/presentation/widgets/map/volcanic_kernel_sheet_test.dart: the sheet of
## the volcano, guarded by the kraken or held by the player.

const Harpoonist := UnitType.Value.HARPOONIST

var _told: Array[String] = []


func _sheet(captured: bool, plan: Control = null) -> VolcanicKernelSheet:
	var war := KernelWar.new(3, 7, captured)
	var sheet := VolcanicKernelSheet.new(war.game, captured, plan)
	sheet.attack_requested.connect(func() -> void: _told.append("attack"))
	sheet.garrison_requested.connect(func() -> void: _told.append("garrison"))
	sheet.withdraw_requested.connect(func() -> void: _told.append("withdraw"))
	modals().open(sheet)
	return sheet


func test_a_guarded_kernel_shows_its_description_and_the_assault() -> void:
	var sheet := _sheet(false)
	assert_eq(sheet.title_label.text, "Noyau Volcanique")
	assert_eq(sheet.description_label.text, "Le cœur brûlant des abysses est gardé par de puissants gardiens.")
	assert_not_null(find_text("Lancer l'assaut", sheet))
	assert_null(sheet.garrison_panel)
	assert_no_raw_keys(sheet)


func test_the_plan_comes_before_the_assault_button() -> void:
	var plan := Label.new()
	plan.text = "Plan"
	var order := texts(_sheet(false, plan))
	assert_true(order.find("Plan") < order.find("Lancer l'assaut"))


func test_the_assault_closes_the_sheet_and_tells_it_once() -> void:
	var sheet := _sheet(false)
	press("Lancer l'assaut")
	assert_eq(_told, ["attack"] as Array[String])
	assert_true(sheet.is_closed())


func test_a_held_kernel_shows_its_garrison_and_no_assault() -> void:
	var sheet := _sheet(true)
	assert_true(sheet.description_label.text.begins_with("Tu as capturé le Noyau Volcanique."))
	assert_not_null(sheet.garrison_panel)
	assert_null(sheet.attack_button)
	assert_null(find_text("Lancer l'assaut", sheet))
	assert_no_raw_keys(sheet)


func test_the_garrison_buttons_close_the_sheet_then_tell() -> void:
	var sheet := _sheet(true)
	sheet.garrison_panel.withdraw_button.disabled = false
	press("Retirer")
	assert_eq(_told, ["withdraw"] as Array[String])
	assert_true(sheet.is_closed())
	modals().close_top()
	press(_sheet(true).garrison_panel.garrison_button)
	assert_eq(_told, ["withdraw", "garrison"] as Array[String])


func test_the_halo_follows_the_guide() -> void:
	var war := KernelWar.new(3, 7, true)
	ObjectiveMigration.state_of(war.game, war.human()).tutorial_enabled = false
	var sheet := VolcanicKernelSheet.new(war.game, true)
	modals().open(sheet)
	assert_false(sheet.garrison_panel.halo.active)


func test_the_sheet_speaks_english() -> void:
	var sheet := _sheet(false)
	use_language("en")
	assert_eq(sheet.title_label.text, "Volcanic Core")
	assert_not_null(find_text("Launch the assault", sheet))
	assert_no_raw_keys(sheet)
