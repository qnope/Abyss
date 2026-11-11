extends UiTestCase
## A research node in each state (tech_node_widget_test.dart).

const Branch := TechBranch.Value
const State := TechNodeState.Value

var _taps := 0


func _node(state: TechNodeState.Value, option: Variant = TechOption.Value.A) -> TechNode:
	var node := TechNode.new(Branch.MILITARY, 2, option, state, 40.0)
	node.tapped.connect(func() -> void: _taps += 1)
	return mount(node) as TechNode


func _box(node: TechNode) -> StyleBoxFlat:
	return node.get_theme_stylebox(&"panel") as StyleBoxFlat


func test_shows_the_icon_of_its_technology() -> void:
	var node := _node(State.RESEARCHED)
	assert_eq(node.icon.icon_path, "res://assets/icons/tech/military_2a.svg")
	assert_almost_eq(node.icon.custom_minimum_size.x, 40.0 * TechNode.ICON_SHARE, 0.01)
	assert_eq(node.custom_minimum_size, Vector2(40, 40))


func test_a_researched_node_glows_in_the_colour_of_its_branch() -> void:
	var node := _node(State.RESEARCHED)
	assert_eq(_box(node).border_color, AbyssColors.BIOLUM_PINK)
	assert_true(_box(node).shadow_size > 0)
	assert_null(node.icon.material, "in colour")
	assert_eq(node.icon.modulate.a, 1.0)
	assert_null(node.strike)


func test_the_next_node_is_ringed_and_in_colour() -> void:
	var node := _node(State.ACCESSIBLE)
	assert_eq(_box(node).border_color, Color(AbyssColors.BIOLUM_PINK, 0.8))
	assert_null(node.icon.material)
	assert_null(node.strike)


func test_a_locked_node_shows_its_icon_faded_in_grey() -> void:
	var node := _node(State.LOCKED)
	assert_not_null(node.icon.material)
	assert_almost_eq(node.icon.modulate.a, AbyssColors.UNAVAILABLE_OPACITY, 0.001)
	assert_eq(_box(node).border_color, AbyssColors.SURFACE_BRIGHT)
	assert_eq(_box(node).shadow_size, 0)


func test_the_option_left_aside_is_grey_and_struck_through() -> void:
	var node := _node(State.DISCARDED)
	assert_not_null(node.icon.material)
	assert_eq(node.icon.modulate.a, 1.0)
	assert_not_null(node.strike)
	assert_eq(node.strike.points.size(), 2)
	assert_eq(node.strike.default_color, AbyssColors.ON_SURFACE_DIM)
	assert_eq(_box(node).border_color, AbyssColors.SURFACE_BRIGHT)


func test_a_touch_tells_it() -> void:
	var node := _node(State.LOCKED)
	press(node.tap_button)
	assert_eq(_taps, 1)


func test_is_named_for_a_screen_reader() -> void:
	var node := _node(State.LOCKED)
	assert_eq(node.tap_button.accessibility_name, TechNodeTexts.node_name(Branch.MILITARY, 2, TechOption.Value.A))
