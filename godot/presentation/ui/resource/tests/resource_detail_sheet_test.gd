extends UiTestCase
## The detail of a resource, from a touch on the bar
## (resource_detail_sheet_test.dart).

const Type := ResourceType.Value


func test_describes_the_resource_and_its_stock() -> void:
	var sheet := _sheet(Type.CORAL, 42, 0)
	assert_eq(sheet.name_label.text, "Corail")
	assert_eq(sheet.flavor_label.text, ResourceTexts.flavor_text(Type.CORAL))
	assert_eq(sheet.stock_label.text, "42 / 300")
	assert_eq(sheet.name_label.get_theme_color(&"font_color"), AbyssColors.CORAL_PINK)
	assert_eq((find_type("TextureRect", sheet)[0] as ResourceIcon).type, Type.CORAL)
	assert_false(sheet.production_box.visible)
	assert_no_raw_keys()


func test_shows_the_production_per_turn_when_positive() -> void:
	var sheet := _sheet(Type.CORAL, 42, 12)
	assert_true(sheet.production_box.visible)
	assert_not_null(find_text("Production", sheet))
	assert_not_null(find_text("Bâtiment principal", sheet))
	assert_eq(sheet.production_label.text, "+12/t")
	assert_eq(sheet.production_label.get_theme_color(&"font_color"), AbyssColors.CORAL_PINK)


func test_follows_the_language() -> void:
	var sheet := _sheet(Type.CORAL, 42, 12)
	use_language("es")
	assert_eq(sheet.name_label.text, "Coral")
	assert_not_null(find_text("Producción", sheet))
	assert_not_null(find_text("Edificio principal", sheet))


func test_is_a_bottom_sheet_the_player_can_dismiss() -> void:
	var sheet := _sheet(Type.PEARL, 5, 0)
	assert_eq(sheet.placement, ModalPanel.Placement.BOTTOM)
	modals().close_top()
	assert_null(current_modal())


func _sheet(type: ResourceType.Value, amount: int, production: int) -> ResourceDetailSheet:
	var sheet := ResourceDetailSheet.new(GameResource.new(type, amount, 300), production)
	modals().open(sheet)
	return sheet
