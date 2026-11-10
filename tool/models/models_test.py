"""Builds every model of the catalog in a temporary folder and checks the glb:
valid, with the nodes the game relies on, under its budget, the same from one
build to the next, and the same as the one committed in the game."""

import glob
import os
import unittest

from catalog import MODELS
from model_builds import built, committed, rebuilt
from workshop.glb import read_glb


class ModelsTest(unittest.TestCase):
    def test_every_model_is_a_glb_with_its_nodes(self):
        for name, script in MODELS.items():
            with self.subTest(name):
                path, report = built(name)
                self.assertEqual(read_glb(path).paths, report.paths)
                for node in script.NODES:
                    self.assertIn(node, report.paths)

    def test_every_model_stays_under_its_budget(self):
        for name, script in MODELS.items():
            with self.subTest(name):
                self.assertEqual(script.BUDGET.overruns(built(name)[1]), [])

    def test_every_model_uses_only_its_materials(self):
        for name, script in MODELS.items():
            with self.subTest(name):
                allowed = {material.name for material in script.MATERIALS}
                self.assertLessEqual(set(built(name)[1].materials), allowed)

    def test_every_model_builds_the_same_geometry_twice(self):
        for name in MODELS:
            with self.subTest(name):
                self.assertEqual(rebuilt(name)[1].geometry_hash, built(name)[1].geometry_hash)

    def test_every_committed_model_is_what_its_script_builds(self):
        for name in MODELS:
            with self.subTest(name):
                self.assertTrue(os.path.exists(committed(name)), f"run tool/models/build.py {name}")
                self.assertEqual(read_glb(committed(name)).geometry_hash,
                                 built(name)[1].geometry_hash,
                                 f"godot/assets/models/{name}.glb is stale: rebuild it")

    def test_every_committed_model_has_a_script(self):
        folder = os.path.dirname(committed("any"))
        names = {os.path.basename(path)[:-4] for path in glob.glob(os.path.join(folder, "*.glb"))}
        self.assertEqual(names, set(MODELS))


if __name__ == "__main__":
    unittest.main()
