"""Runs tool/godot_coverage.py with Godot on a copy of the project that
holds fixtures/calc.gd, whose test calls it in a known way."""

import os
import shutil
import tempfile
import unittest

from gdscript_coverage import cli
from gdscript_coverage.godot import CoverageError, check_scripts
from gdscript_coverage.project import Script

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.join(os.path.dirname(os.path.dirname(HERE)), "godot")
CALC = """SF:godot/coverage_fixture/calc.gd
DA:9,1
DA:13,2
DA:14,1
DA:15,1
DA:17,0
DA:18,1
DA:22,1
DA:24,1
DA:25,0
DA:29,1
DA:30,1
DA:31,2
DA:33,1
DA:37,0
DA:44,1
DA:45,1
LF:16
LH:13
end_of_record
"""


@unittest.skipUnless(shutil.which(os.environ.get("GODOT", "godot")), "needs Godot")
class EndToEndTest(unittest.TestCase):
    def setUp(self):
        self.root = tempfile.mkdtemp()
        self.project = os.path.join(self.root, "godot")
        shutil.copytree(PROJECT, self.project, ignore=shutil.ignore_patterns(".godot"))
        fixture = os.path.join(self.project, "coverage_fixture")
        os.mkdir(fixture)
        for name in ["calc.gd", "calc_test.gd"]:
            shutil.copy(os.path.join(HERE, "fixtures", name), fixture)
        self.out = os.path.join(self.root, "coverage", "lcov.info")

    def tearDown(self):
        shutil.rmtree(self.root)

    def run_tool(self, *paths):
        return cli.main(["--project", self.project, "--out", self.out, *paths])

    def test_lists_the_hit_and_missed_lines_of_each_script(self):
        self.assertEqual(self.run_tool("godot/coverage_fixture"), 0)
        with open(self.out) as file:
            records = file.read().split("end_of_record\n")
        self.assertIn(CALC, [record + "end_of_record\n" for record in records])
        main = [r for r in records if r.startswith("SF:godot/app/main.gd\n")]
        self.assertEqual(len(main), 1)
        self.assertRegex(main[0], r"DA:14,0\nDA:15,0\nLF:2\nLH:0\n$")
        self.assertTrue(os.path.exists(os.path.join(self.root, "coverage", "summary.md")))

    def test_fails_when_a_test_fails(self):
        self.assertEqual(self.run_tool("tool/test/fixtures/failing_test.gd"), 1)
        self.assertTrue(os.path.exists(self.out))

    def test_names_the_line_of_a_probe_that_breaks_a_script(self):
        script = "extends Node\nfunc f() -> void:\n\tCoverageProbe.hit(0, 3); else: pass\n"
        os.makedirs(os.path.join(self.project, "broken"))
        with open(os.path.join(self.project, "broken", "x.gd"), "w") as file:
            file.write(script)
        broken = Script("broken/x.gd", 0, [3], 4, script)
        with self.assertRaises(CoverageError) as raised:
            check_scripts(self.project, [broken], "godot")
        self.assertIn("godot/broken/x.gd:3: the instrumented script does not parse", str(raised.exception))
        self.assertIn('Expected statement, found "else" instead.', str(raised.exception))
        self.assertIn("\tCoverageProbe.hit(0, 3); else: pass", str(raised.exception))


if __name__ == "__main__":
    unittest.main()
