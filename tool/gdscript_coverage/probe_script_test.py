import unittest

from gdscript_coverage.probe_script import probe_script, read_hits


class ProbeScriptTest(unittest.TestCase):
    def test_gives_each_file_a_slot_per_line_number(self):
        script = probe_script([3, 2])
        self.assertTrue(script.startswith("class_name CoverageProbe\n"))
        self.assertIn("const OFFSETS: Array[int] = [0, 4]\n", script)
        self.assertIn("const SIZE := 7\n", script)
        self.assertIn("static func hit(file: int, line: int) -> void:\n", script)
        self.assertIn("static func dump(path: String) -> Error:\n", script)

    def test_reads_the_dump_back_per_file_and_line(self):
        self.assertEqual(read_hits("0 1 0 2  0 0 5\n", [3, 2]), [[0, 1, 0, 2], [0, 0, 5]])

    def test_rejects_a_dump_of_the_wrong_size(self):
        with self.assertRaisesRegex(ValueError, "7 slots expected, 2 found"):
            read_hits("1 2", [3, 2])


if __name__ == "__main__":
    unittest.main()
