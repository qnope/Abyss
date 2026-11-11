extends MapSheetCase
## test/presentation/widgets/map/cell_info_sheet_test.dart: a title and a
## message, with or without a picture.


func _open(picture: Control = null) -> CellInfoSheet:
	var sheet := CellInfoSheet.new(picture, func() -> String: return Texts.t(&"screenYourBaseTitle"),
		func() -> String: return Texts.t(&"screenYourBaseMessage"))
	modals().open(sheet)
	return sheet


func test_shows_the_title_and_the_message() -> void:
	var sheet := _open()
	assert_eq(sheet.title_label.text, "Votre base")
	assert_eq(sheet.message_label.text, "Votre quartier général")
	assert_no_raw_keys()


func test_shows_the_picture_above_the_title() -> void:
	var picture := UiIcon.glyph(&"home", 64.0)
	var sheet := _open(picture)
	assert_eq(sheet.column.get_child(0), picture)


func test_follows_the_language() -> void:
	var sheet := _open()
	use_language("en")
	assert_eq(sheet.title_label.text, "Your base")
	assert_eq(sheet.message_label.text, "Your headquarters")
