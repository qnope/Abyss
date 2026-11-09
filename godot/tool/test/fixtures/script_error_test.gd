extends TestCase
## A fixture whose first test hits a script error: it must fail without
## stopping the run.


func test_calls_a_method_on_null() -> void:
	var nothing: Object = null
	nothing.free()


func test_still_runs() -> void:
	assert_true(true)
