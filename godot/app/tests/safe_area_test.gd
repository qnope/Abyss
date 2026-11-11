extends TestCase
## SafeArea tells how far down the notch reaches.


func test_the_top_edge_is_what_lies_above_the_safe_area() -> void:
	assert_eq(SafeArea.top_in(Rect2i(0, 120, 1170, 2200), 0.5), 60)
	assert_eq(SafeArea.top_in(Rect2i(0, 0, 1170, 2200), 0.5), 0)


func test_there_is_no_edge_when_the_system_gives_no_area() -> void:
	assert_eq(SafeArea.top_in(Rect2i(), 0.5), 0)


func test_reads_the_screen_of_the_viewport() -> void:
	var root := (Engine.get_main_loop() as SceneTree).root
	assert_true(SafeArea.top(root) >= 0)
