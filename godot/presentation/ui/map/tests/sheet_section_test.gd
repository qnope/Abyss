extends UiTestCase
## SheetSection: the labels, buttons and rebuilt parts of a map sheet's section
## follow the language.

var _built := 0


func _section() -> SheetSection:
	var section := SheetSection.new()
	section.column.add_child(section.label(func() -> String: return Texts.t(&"commonCancel"), &"BodySmall", AbyssColors.ERROR))
	section.column.add_child(section.button(func() -> String: return Texts.t(&"commonOk")))
	section.column.add_child(section.swap(func() -> Control:
		_built += 1
		var made := Label.new()
		made.text = "built %d in %s" % [_built, Texts.t(&"commonOk")]
		return made))
	return mount(section) as SheetSection


func test_the_texts_are_written_when_built() -> void:
	var section := _section()
	assert_not_null(find_text("Annuler", section))
	assert_not_null(find_text("OK", section))
	assert_eq(_built_labels(section).size(), 1)


func test_a_label_wears_its_style_and_ink() -> void:
	var made := _section().label(func() -> String: return "x", &"BodySmall", AbyssColors.ERROR)
	assert_eq(made.theme_type_variation, &"BodySmall")
	assert_eq(made.get_theme_color(&"font_color"), AbyssColors.ERROR)
	made.free()


func test_a_change_of_language_writes_every_text_and_builds_the_swapped_part_again() -> void:
	var section := _section()
	use_language("en")
	assert_not_null(find_text("Cancel", section))
	assert_null(find_text("Annuler", section))
	var built_before := _built
	use_language("fr")
	assert_true(_built > built_before, "the part is built again")
	assert_eq(_built_labels(section).size(), 1, "the old part is gone")
	assert_eq((_built_labels(section)[0] as Label).text, "built %d in OK" % _built)


func _built_labels(section: SheetSection) -> Array[Node]:
	return section.find_children("*", "Label", true, false).filter(
		func(l: Label) -> bool: return l.text.begins_with("built"))
