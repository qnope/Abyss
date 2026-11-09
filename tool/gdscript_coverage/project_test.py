import os
import shutil
import tempfile
import unittest

from gdscript_coverage.project import PROBE_PATH, game_scripts, instrument_copy


def write(root, path, text):
    full = os.path.join(root, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as file:
        file.write(text)


class ProjectTest(unittest.TestCase):
    def setUp(self):
        self.root = tempfile.mkdtemp()
        self.project = os.path.join(self.root, "godot")
        for path in ["domain/unit.gd", "app/main.gd", "app/main_test.gd", "tool/test/run.gd",
                     ".godot/cache.gd", "assets/.hidden/x.gd", "domain/notes.txt"]:
            write(self.project, path, "func f() -> void:\n\tpass\n")

    def tearDown(self):
        shutil.rmtree(self.root)

    def test_game_scripts_leave_out_tests_tools_and_hidden_folders(self):
        self.assertEqual(game_scripts(self.project), ["app/main.gd", "domain/unit.gd"])

    def test_instruments_a_copy_and_adds_the_probe_class(self):
        copy = os.path.join(self.root, "copy")
        files = instrument_copy(self.project, copy)
        self.assertEqual([(f.path, f.index, f.lines) for f in files],
                         [("app/main.gd", 0, [2]), ("domain/unit.gd", 1, [2])])
        with open(os.path.join(copy, "domain/unit.gd")) as file:
            self.assertEqual(file.read(), "func f() -> void:\n\tCoverageProbe.hit(1, 2); pass\n")
        with open(os.path.join(copy, "app/main_test.gd")) as file:
            self.assertEqual(file.read(), "func f() -> void:\n\tpass\n")
        with open(os.path.join(copy, PROBE_PATH)) as file:
            self.assertIn("const OFFSETS: Array[int] = [0, 4]", file.read())
        self.assertFalse(os.path.exists(os.path.join(copy, ".godot")))
        with open(os.path.join(self.project, "domain/unit.gd")) as file:
            self.assertEqual(file.read(), "func f() -> void:\n\tpass\n")


if __name__ == "__main__":
    unittest.main()
