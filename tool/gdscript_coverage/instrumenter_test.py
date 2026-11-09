import unittest

from gdscript_coverage.instrumenter import instrument


class InstrumenterTest(unittest.TestCase):
    def test_puts_each_probe_on_its_line_before_the_statement(self):
        source = """extends Node
## Doc.
var hp := 0:
	set(value): hp = value


func f(x: int) -> int:
	var y := [x,
		1]
	if x > 0:
		return x
	elif x == 0: return 0
	else:
		pass
	match x:
		1:
			return 1
	return y.size()
"""
        expected = """extends Node
## Doc.
var hp := 0:
	set(value): CoverageProbe.hit(3, 4); hp = value


func f(x: int) -> int:
	CoverageProbe.hit(3, 8); var y := [x,
		1]
	CoverageProbe.hit(3, 10); if x > 0:
		CoverageProbe.hit(3, 11); return x
	elif x == 0: CoverageProbe.hit(3, 12); return 0
	else:
		CoverageProbe.hit(3, 14); pass
	CoverageProbe.hit(3, 15); match x:
		1:
			CoverageProbe.hit(3, 17); return 1
	CoverageProbe.hit(3, 18); return y.size()
"""
        result = instrument(source, 3)
        self.assertEqual(result.text, expected)
        self.assertEqual(result.lines, [4, 8, 10, 11, 12, 14, 15, 17, 18])
        self.assertEqual(result.line_count, 19)

    def test_keeps_the_line_count_and_windows_line_endings(self):
        source = "func f() -> void:\r\n\tpass\r\n"
        result = instrument(source, 0)
        self.assertEqual(result.text, "func f() -> void:\r\n\tCoverageProbe.hit(0, 2); pass\r\n")
        self.assertEqual(result.text.count("\n"), source.count("\n"))

    def test_leaves_a_script_without_functions_as_it_is(self):
        source = "class_name Data\nconst A := 1\n"
        result = instrument(source, 0)
        self.assertEqual((result.text, result.lines), (source, []))


if __name__ == "__main__":
    unittest.main()
