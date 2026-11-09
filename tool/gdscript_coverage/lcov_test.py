import unittest

from gdscript_coverage.lcov import FileCoverage, lcov


class LcovTest(unittest.TestCase):
    def test_writes_a_record_per_file_with_its_hit_and_missed_lines(self):
        files = [
            FileCoverage("godot/domain/b.gd", [2, 5], [0, 0, 3, 0, 0, 0]),
            FileCoverage("godot/app/a.gd", [4], [0, 0, 0, 0, 0]),
            FileCoverage("godot/app/empty.gd", [], [0]),
        ]
        self.assertEqual(lcov(files), """SF:godot/app/a.gd
DA:4,0
LF:1
LH:0
end_of_record
SF:godot/app/empty.gd
LF:0
LH:0
end_of_record
SF:godot/domain/b.gd
DA:2,3
DA:5,0
LF:2
LH:1
end_of_record
""")

    def test_counts_the_lines_found_and_hit(self):
        file = FileCoverage("x.gd", [1, 2, 3], [0, 1, 0, 9])
        self.assertEqual((file.found(), file.hit()), (3, 2))


if __name__ == "__main__":
    unittest.main()
