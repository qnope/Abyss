extends UiTestCase
## The gains of a resource, in a row and in a dialog
## (resource_gains_row_test.dart, resource_gain_dialog_test.dart).

const Type := ResourceType.Value


func test_a_row_shows_each_gain_in_the_colour_of_its_resource() -> void:
	var row := mount(ResourceGainsRow.new(_gains({Type.CORAL: 30, Type.ORE: 20}))) as ResourceGainsRow
	assert_eq(texts(row), PackedStringArray(["+30", "+20"]))
	assert_eq(find_text("+30", row).get_theme_color(&"font_color"), AbyssColors.CORAL_PINK)
	assert_eq(find_text("+20", row).get_theme_color(&"font_color"), AbyssColors.ORE_BLUE)
	assert_eq(find_type("TextureRect", row).size(), 2)


func test_a_row_leaves_out_what_was_not_gained() -> void:
	var row := mount(ResourceGainsRow.new(_gains({Type.ALGAE: 0, Type.ENERGY: 4}))) as ResourceGainsRow
	assert_eq(texts(row), PackedStringArray(["+4"]))


func test_a_dialog_lists_the_gains_in_the_order_of_the_resources() -> void:
	var dialog := _dialog("Ruines", _gains({Type.ORE: 20, Type.ALGAE: 5, Type.PEARL: 0}))
	assert_eq(dialog.title(), "Ruines")
	assert_eq(texts(dialog.body), PackedStringArray(["Algues", "+5", "Minerai", "+20"]))
	assert_eq(find_text("+5", dialog).get_theme_color(&"font_color"), AbyssColors.ALGAE_GREEN)
	assert_eq(dialog.actions().size(), 1)
	assert_eq(dialog.actions()[0].text, "OK")
	assert_no_raw_keys()


func test_a_dialog_with_nothing_says_so_or_what_it_is_told() -> void:
	assert_not_null(find_text("Rien à récupérer ici...", _dialog("Ruines", _gains({Type.ALGAE: 0}))))
	var told := _dialog("Épave", _gains({}), "Rien à voir")
	assert_not_null(find_text("Rien à voir", told))
	assert_null(find_text("Rien à récupérer ici...", told))


func test_a_dialog_follows_the_language() -> void:
	var dialog := _dialog("Ruins", _gains({Type.CORAL: 3}))
	var empty := _dialog("Ruins", _gains({}))
	use_language("en")
	assert_not_null(find_text("Coral", dialog))
	assert_eq(dialog.actions()[0].text, "OK")
	assert_not_null(find_text("Nothing to collect here...", empty))


func test_ok_ends_the_dialog() -> void:
	var dialog := _dialog("Ruines", _gains({Type.ALGAE: 1}))
	press("OK")
	assert_true(dialog.is_closed())
	assert_null(current_modal())


func _dialog(title: String, gains: Dictionary[ResourceType.Value, int], empty := "") -> ResourceGainDialog:
	var dialog := ResourceGainDialog.new(title, gains, empty)
	modals().open(dialog)
	return dialog


static func _gains(values: Dictionary) -> Dictionary[ResourceType.Value, int]:
	var gains: Dictionary[ResourceType.Value, int] = {}
	gains.assign(values)
	return gains
