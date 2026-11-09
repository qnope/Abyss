extends RefCounted
## Known calls for the end-to-end test of tool/godot_coverage.py: calc_test.gd
## runs some of its lines, some twice, and leaves others out.

const LIMIT := 10

var total: int = 0:
	set(value):
		total = mini(value, LIMIT)


func add(amount: int) -> int:
	if amount > 0:
		total += amount
	elif amount == 0: return total
	else:
		total -= 1
	return total


func describe(value: int) -> String:
	match value:
		1:
			return "one"
		_: return "many"


func doubled(values: Array[int]) -> Array[int]:
	var result: Array[int] = []
	result.assign(values.map(func(v: int) -> int:
		return v * 2
	))
	return result


static func never_called() -> void:
	print("never")


class Counter:
	var count := 0

	func bump() -> int:
		count += 1
		return count
