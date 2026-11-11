extends UiTestCase
## A line of information in a small rimmed box (worksite_badge.dart).

const PATH := "res://assets/icons/ui/lock.svg"


func test_says_its_text_in_its_colour() -> void:
	var badge := InfoBadge.new(PATH, AbyssColors.CORAL_PINK, "Hello")
	mount(badge)
	assert_eq(badge.label.text, "Hello")
	assert_eq(badge.icon.self_modulate, AbyssColors.CORAL_PINK)
	assert_not_null(find_text("Hello", badge))


func test_changes_its_text_and_colour() -> void:
	var badge := InfoBadge.new(PATH, AbyssColors.CORAL_PINK, "Hello")
	mount(badge)
	badge.show_text("Bye", AbyssColors.WARNING)
	assert_eq(badge.label.text, "Bye")
	assert_eq(badge.icon.self_modulate, AbyssColors.WARNING)


func test_lets_the_touches_through_and_keeps_to_its_corner() -> void:
	var badge := InfoBadge.new(PATH, AbyssColors.CORAL_PINK, "Hello")
	mount(badge)
	assert_eq(badge.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(badge.label.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(badge.size_flags_horizontal, Control.SIZE_SHRINK_BEGIN)


func test_keeps_its_text_on_one_line_so_that_the_box_is_as_wide_as_it() -> void:
	var badge := InfoBadge.new(PATH, AbyssColors.CORAL_PINK, "Chantiers libres ce tour : 1/1")
	mount(badge)
	assert_eq(badge.label.autowrap_mode, TextServer.AUTOWRAP_OFF)
	assert_true(badge.get_combined_minimum_size().x > 150.0)
