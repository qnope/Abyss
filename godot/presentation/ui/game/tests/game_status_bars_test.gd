extends UiTestCase
## The strips stacked under the resource bar (game_status_bars.dart): none
## yet, each of the threat, event and objective lots adds its own.


class Strip:
	extends RefreshingPanel

	var refreshed := 0

	func refresh() -> void:
		refreshed += 1


func test_is_empty_until_a_lot_adds_a_strip() -> void:
	var bars := mount(GameStatusBars.new()) as GameStatusBars
	assert_eq(bars.bars(), [] as Array[Control])
	assert_eq(bars.get_combined_minimum_size().y, 0.0)


func test_stacks_the_strips_in_the_order_they_are_added() -> void:
	var bars := mount(GameStatusBars.new()) as GameStatusBars
	var first := Strip.new()
	var second := Strip.new()
	bars.add_bar(first)
	bars.add_bar(second)
	assert_eq(bars.bars(), [first, second] as Array[Control])
	assert_eq(second.get_index(), first.get_index() + 1)


func test_redraws_every_strip_with_the_game() -> void:
	var bars := mount(GameStatusBars.new()) as GameStatusBars
	var strip := Strip.new()
	bars.add_bar(strip)
	var before := strip.refreshed
	bars.refresh()
	assert_eq(strip.refreshed, before + 1)


func test_a_plain_control_is_left_alone() -> void:
	var bars := mount(GameStatusBars.new()) as GameStatusBars
	bars.add_bar(Control.new())
	bars.refresh()
	assert_eq(bars.bars().size(), 1)
