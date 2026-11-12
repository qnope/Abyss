"""The probe fish proves the rigs: its skeleton and its four actions come out
in the glb, loops marked for Godot's importer, and the rest of the workshop
is unchanged by them."""

import unittest

from catalog import probe_fish
from model_builds import built
from workshop.model import Model


class ProbeFishTest(unittest.TestCase):
    def setUp(self):
        self.report = built("probe_fish")[1]

    def test_has_a_skeleton_of_a_body_and_a_three_bone_tail(self):
        self.assertEqual(self.report.bones, 4)
        for bone in ("Body", "Body/Tail1", "Body/Tail1/Tail2", "Body/Tail1/Tail2/Tail3"):
            self.assertIn(f"Rig/{bone}", self.report.paths)

    def test_skins_its_meshes_to_the_skeleton(self):
        skins = self.report.document["skins"]
        self.assertEqual(len(skins), 1)
        nodes = self.report.document["nodes"]
        skinned = [node["name"] for node in nodes if "skin" in node]
        self.assertEqual(sorted(skinned), ["ProbeFish_coral", "ProbeFish_glow"])
        attributes = self.report.document["meshes"][0]["primitives"][0]["attributes"]
        self.assertIn("JOINTS_0", attributes)
        self.assertIn("WEIGHTS_0", attributes)

    def test_exports_its_four_actions_the_loops_marked_for_the_importer(self):
        self.assertEqual(sorted(self.report.animations),
                         ["attack", "hit", "idle_loop", "swim_loop"])

    def test_counts_its_keyframes_and_stays_under_its_budget(self):
        self.assertGreater(self.report.keyframes, 100)
        self.assertEqual(probe_fish.BUDGET.overruns(self.report), [])

    def test_a_loop_comes_back_to_its_first_pose(self):
        for action in _declared().rig.actions:
            for keys in action.tracks.values() if action.loop else []:
                self.assertEqual(keys[0].rotation, keys[-1].rotation)

    def test_the_tail_is_blended_along_its_bones(self):
        weights = _declared()._groups["ProbeFish"]["coral"].weights[-25:]
        self.assertEqual(set(weights[0]), {"Tail1"})
        self.assertTrue(any(len(w) == 2 for w in weights))
        self.assertTrue(all(abs(sum(w.values()) - 1) < 1e-9 for w in weights))


def _declared():
    """The probe fish's script run on a Model, with nothing built in Blender."""
    model = Model("probe_fish", probe_fish.SEED, probe_fish.MATERIALS)
    probe_fish.build(model)
    return model


if __name__ == "__main__":
    unittest.main()
