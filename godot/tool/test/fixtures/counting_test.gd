extends TestCase
## A fixture that passes only when ResetProbe starts from zero, so twice in a
## row only if its reset ran in between.

const ResetProbe := preload("res://tool/test/fixtures/reset_probe.gd")


func test_starts_from_zero() -> void:
	assert_eq(ResetProbe.count, 0)
	ResetProbe.count += 1
