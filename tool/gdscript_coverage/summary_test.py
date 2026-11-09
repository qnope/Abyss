"""The Godot paths of an lcov file go through
.github/scripts/coverage_summary.sh as they are (its Flutter side is
tested in test/tool/coverage_summary_test.dart)."""

import os
import subprocess
import tempfile
import unittest

from gdscript_coverage.cli import SUMMARY


def summary(lcov):
    with tempfile.NamedTemporaryFile("w", suffix=".info") as file:
        file.write(lcov)
        file.flush()
        return subprocess.run(["bash", SUMMARY, file.name], capture_output=True, text=True,
                              env=dict(os.environ, COVERAGE_MIN="")).stdout


class SummaryTest(unittest.TestCase):
    def test_keeps_godot_paths_even_with_a_lib_folder(self):
        report = summary("SF:godot/presentation/lib/x.gd\nDA:3,1\nLF:2\nLH:1\nend_of_record\n"
                         "SF:godot/app/main.gd\nDA:3,1\nLF:2\nLH:2\nend_of_record\n")
        self.assertIn("## Code coverage: 75.0%", report)
        self.assertIn("| `godot/presentation` | 2 | 1 |", report)
        self.assertIn("| `godot/presentation/lib/x.gd` | 2 | 1 |", report)
        self.assertIn("| `godot/app/main.gd` | 2 | 2 |", report)


if __name__ == "__main__":
    unittest.main()
