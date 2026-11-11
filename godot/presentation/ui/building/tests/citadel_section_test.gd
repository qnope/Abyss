extends BuildingTestCase
## What the Coral Citadel gives (coral_citadel_info_section_test.dart).

const Type := BuildingType.Value


func _section(level: int) -> CitadelSection:
	set_levels({Type.CORAL_CITADEL: level})
	var section := CitadelSection.new(human.buildings[Type.CORAL_CITADEL])
	mount(section)
	return section


func test_unbuilt_it_raises_no_rampart_yet() -> void:
	var section := _section(0)
	assert_eq(section.current_label.text, "Rempart actuel : " + RampartTexts.coral(0))
	assert_eq(section.current_label.get_theme_color(&"font_color"), AbyssColors.DISABLED)
	assert_eq(section.next_label.text, "Prochain niveau : 40 PV, DEF 5")


func test_built_it_tells_the_rampart_and_the_next() -> void:
	var section := _section(2)
	assert_eq(section.current_label.text, "Rempart actuel : 80 PV, DEF 6")
	assert_eq(section.current_label.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE)
	assert_eq(section.next_label.text, "Prochain niveau : 120 PV, DEF 7")
	assert_eq(section.hint_label.text, Texts.t(&"baseRampartHint"))


func test_at_its_top_level_it_has_no_next_rampart() -> void:
	var top := BuildingCostCalculator.new().max_level(Type.CORAL_CITADEL)
	var section := _section(top)
	assert_eq(section.next_label.text, Texts.t(&"baseRampartMax"))
	assert_no_raw_keys()
