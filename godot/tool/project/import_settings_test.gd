extends TestCase
## How the project imports its assets, in the editor and in CI.


func test_imports_on_a_single_thread() -> void:
	var threaded: bool = ProjectSettings.get_setting("editor/import/use_multiple_threads")
	assert_false(threaded, "Godot 4.7.2 crashes or hangs on a font about once in 15 threaded imports")
