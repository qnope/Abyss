extends TestCase
## A fixture that logs its hooks and tests in order, each test checking that
## it runs on a fresh instance.

static var events: PackedStringArray = PackedStringArray()

var _hooked: int = 0


func before_each() -> void:
	events.append("before")
	_hooked += 1
	add_cleanup(func() -> void: events.append("cleanup first"))
	add_cleanup(func() -> void: events.append("cleanup last"))


func after_each() -> void:
	events.append("after")


func test_first() -> void:
	events.append("first")
	assert_eq(_hooked, 1)


func test_second() -> void:
	events.append("second")
	assert_eq(_hooked, 1)
