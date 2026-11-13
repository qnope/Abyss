"""Tests of simulations.py: python3 -m unittest discover -s tool -p '*_test.py'"""

import contextlib
import io
import os
import tempfile
import unittest

import simulations

CASES = """# a comment

short: --strategy balanced --games 3
json:   --json   --seed 5
"""


class FakeEngine:
    """Answers the options joined by spaces, and fails on `--boom`."""

    def __init__(self):
        self.calls = []

    def __call__(self, command, options):
        self.calls.append((command, options))
        if "--boom" in options:
            raise simulations.SimulationError("exit status 255")
        return " ".join(options) + "\n"


class ParseTest(unittest.TestCase):
    def test_reads_the_cases_in_order_without_comments(self):
        self.assertEqual(
            simulations.parse_cases(CASES),
            {"short": ["--strategy", "balanced", "--games", "3"], "json": ["--json", "--seed", "5"]},
        )

    def test_refuses_a_line_without_a_name(self):
        with self.assertRaisesRegex(ValueError, "line 1"):
            simulations.parse_cases("--strategy balanced\n")

    def test_refuses_a_name_given_twice(self):
        with self.assertRaisesRegex(ValueError, "twice: a"):
            simulations.parse_cases("a: --games 1\na: --games 2\n")


class RunTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.mkdtemp()
        with open(os.path.join(self.folder, "cases.txt"), "w", encoding="utf-8") as f:
            f.write(CASES)
        self.engine = FakeEngine()

    def run_main(self, *args):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            status = simulations.main(["--folder", self.folder, *args], self.engine)
        return status, out.getvalue()

    def write(self, name, text):
        with open(os.path.join(self.folder, name + ".txt"), "w", encoding="utf-8") as f:
            f.write(text)

    def write_all(self):
        self.write("short", "--strategy balanced --games 3\n")
        self.write("json", "--json --seed 5\n")

    def test_check_passes_when_every_output_is_the_same(self):
        self.write_all()
        self.assertEqual(self.run_main(), (0, "short: ok\njson: ok\n"))
        self.assertEqual(self.engine.calls[0], (simulations.COMMAND, ["--strategy", "balanced", "--games", "3"]))

    def test_check_fails_naming_a_case_that_differs_or_is_missing(self):
        self.write("short", "something else\n")
        status, out = self.run_main()
        self.assertEqual(status, 1)
        self.assertIn("short: differs\n", out)
        self.assertIn("json: no output yet\n", out)

    def test_check_plays_only_the_cases_named(self):
        self.write_all()
        self.assertEqual(self.run_main("json"), (0, "json: ok\n"))

    def test_an_unknown_case_is_refused(self):
        self.assertEqual(self.run_main("nope"), (1, "nope: no such case in cases.txt\n"))

    def test_a_file_without_a_case_fails_the_check(self):
        self.write_all()
        self.write("old", "x\n")
        status, out = self.run_main()
        self.assertEqual(status, 1)
        self.assertIn("old: no case in cases.txt", out)

    def test_an_engine_that_fails_fails_the_case(self):
        with open(os.path.join(self.folder, "cases.txt"), "a", encoding="utf-8") as f:
            f.write("boom: --boom\n")
        status, out = self.run_main()
        self.assertEqual(status, 1)
        self.assertIn("boom: FAILED, exit status 255", out)


if __name__ == "__main__":
    unittest.main()
