import unittest

from gdscript_coverage.classifier import executable_lines, probes
from gdscript_coverage.tokenizer import tokenize


def lines(source):
    return executable_lines(tokenize(source))


class ClassifierTest(unittest.TestCase):
    def test_class_level_declarations_are_not_executable(self):
        source = """@tool
class_name Unit
extends Node
## Doc.
signal hit(amount: int)
enum Kind { A,
	B }
const MAX := 3
@export var hp := 1
static var count := 0
@onready var label: Label = $Label
var lazy := func(): return 1
"""
        self.assertEqual(lines(source), [])

    def test_function_bodies_count_each_statement_start(self):
        source = """func f(a: int,
		b: int) -> int:
	var x := a + \\
		b

	# comment
	print([x,
		2])
	pass
	return x
"""
        self.assertEqual(lines(source), [3, 7, 9, 10])

    def test_a_multi_line_string_counts_once(self):
        source = 'func f() -> void:\n\tprint("""a\n\tb""")\n\tvar s := "x"\n'
        self.assertEqual(lines(source), [2, 4])

    def test_static_functions_and_inner_classes(self):
        source = """static func s() -> int:
	return 1
class Inner extends RefCounted:
	var v := 1
	func m() -> int:
		return v
	class Deeper:
		static func d() -> void:
			pass
func after() -> void:
	pass
"""
        self.assertEqual(lines(source), [2, 6, 9, 11])

    def test_branches_count_their_first_statement_not_elif_or_else(self):
        source = """func f(x: int) -> int:
	if x > 0:
		x += 1
	elif x < 0:
		x -= 1
	else:
		pass
	for i in x: print(i)
	while x > 9:
		x -= 1
	if x: return 1
	return x
"""
        self.assertEqual(lines(source), [2, 3, 5, 7, 8, 9, 10, 11, 12])

    def test_match_counts_the_match_and_the_bodies_not_the_patterns(self):
        source = """func f(x: Variant) -> int:
	match x:
		1, 2:
			return 1
		[var a, ..]:
			return a
		{"k": var v} when v > 0:
			return v
		_:
			pass
	return 0
"""
        self.assertEqual(lines(source), [2, 4, 6, 8, 10, 11])

    def test_lambda_bodies_on_their_own_lines(self):
        source = """func f(a: Array) -> void:
	var g := func(x: int) -> int:
		return x * 2
	a.sort_custom(func(x: int, y: int) -> bool:
		if x == y:
			return false
		return x < y
	)
	a.map(func(x): return x)
"""
        self.assertEqual(lines(source), [2, 3, 4, 5, 6, 7, 9])

    def test_property_accessors_are_function_bodies(self):
        source = """var hp: int = 0:
	set(value):
		hp = value
	get:
		return hp
var mp: int:
	get = get_mp, set = set_mp
"""
        self.assertEqual(lines(source), [3, 5])

    def test_annotations_in_a_body_are_not_executable_but_their_target_is(self):
        source = """func f() -> void:
	@warning_ignore("unused_variable")
	var a := 1
	@warning_ignore("unused_variable") var b := 2
"""
        self.assertEqual(lines(source), [3, 4])

    def test_one_line_bodies_after_a_header_colon(self):
        source = """var hp := 0:
	set(value): hp = value
	get: return hp
func one() -> int: return 1
static func two() -> int: return 2
func f(x: int) -> int:
	if x == 1: return 1
	elif x == {2: 2}[2]: return 2
	else: return 3
	match x:
		4: return 4
"""
        self.assertEqual(lines(source), [2, 3, 4, 5, 7, 8, 9, 10, 11])

    def test_probes_sit_before_the_statement_or_after_the_header_colon(self):
        source = "func f(x: int) -> int:\n\tif x: return 1\n\telse: return 2\nfunc g() -> int: return 0\n"
        self.assertEqual(probes(tokenize(source)), [(2, 1), (3, 7), (4, 17)])


if __name__ == "__main__":
    unittest.main()
