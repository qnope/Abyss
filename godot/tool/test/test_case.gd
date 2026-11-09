class_name TestCase
extends RefCounted
## The base of a test file. Each method named `test_*` is a test, run on a
## fresh instance between the optional before_each() and after_each() hooks.
## A failed assertion is recorded and the test goes on.

var _failures: PackedStringArray = PackedStringArray()


## Runs before each test, on the test's own instance.
func before_each() -> void:
	pass


## Runs after each test, whether it passed or not.
func after_each() -> void:
	pass


## What went wrong in this test so far, one message per failure.
func failures() -> PackedStringArray:
	return _failures


func fail(message: String) -> void:
	_failures.append(message)


func assert_true(value: bool, message := "") -> void:
	if not value:
		_fail_with(message, "expected true, got false")


func assert_false(value: bool, message := "") -> void:
	if value:
		_fail_with(message, "expected false, got true")


## Exact equality, deep through arrays and dictionaries: 1 is not 1.0.
func assert_eq(actual: Variant, expected: Variant, message := "") -> void:
	if not TestValues.equal(actual, expected):
		_fail_with(message, "expected %s, got %s" % [
			TestValues.describe(expected), TestValues.describe(actual)
		])


func assert_ne(actual: Variant, unexpected: Variant, message := "") -> void:
	if TestValues.equal(actual, unexpected):
		_fail_with(message, "expected anything but %s" % TestValues.describe(unexpected))


func assert_almost_eq(actual: float, expected: float, tolerance: float, message := "") -> void:
	if absf(actual - expected) > tolerance:
		_fail_with(message, "expected %s ± %s, got %s" % [
			TestValues.describe(expected), TestValues.describe(tolerance),
			TestValues.describe(actual)
		])


func assert_null(value: Variant, message := "") -> void:
	if value != null:
		_fail_with(message, "expected null, got %s" % TestValues.describe(value))


func assert_not_null(value: Variant, message := "") -> void:
	if value == null:
		_fail_with(message, "expected a value, got null")


## An item of an array or packed array, a key of a dictionary, or a part of
## a string.
func assert_has(container: Variant, item: Variant, message := "") -> void:
	if not TestValues.contains(container, item):
		_fail_with(message, "expected %s to contain %s" % [
			TestValues.describe(container), TestValues.describe(item)
		])


func _fail_with(message: String, reason: String) -> void:
	fail(reason if message.is_empty() else "%s: %s" % [message, reason])
