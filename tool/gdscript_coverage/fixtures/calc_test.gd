extends TestCase
## Calls calc.gd in a known way, for the end-to-end test of the coverage.

const Calc := preload("res://coverage_fixture/calc.gd")


func test_adds_and_describes() -> void:
	var calc := Calc.new()
	assert_eq(calc.add(3), 3)
	assert_eq(calc.add(0), 3)
	assert_eq(calc.describe(1), "one")
	assert_eq(calc.doubled([1, 2]), [2, 4])
	assert_eq(Calc.Counter.new().bump(), 1)
