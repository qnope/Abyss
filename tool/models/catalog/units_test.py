"""The six units of the army: one model per type of the game, rigged and
animated the same way, one figure of a squad standing on the floor."""

import os
import re
import unittest

from catalog import MODELS
from catalog.families import FAMILIES
from model_builds import built
from workshop.model import Model

UNITS = ["scout", "harpoonist", "guardian", "dome_breaker", "abyss_admiral", "saboteur"]
TYPES = os.path.join(os.path.dirname(__file__), "..", "..", "..", "godot", "domain", "unit",
                     "unit_type.gd")
# The heights (m) of the units, to the top of what they carry: a squad of them
# stands on a pad 2.9 m wide, a cell of the parade ground being 1.15.
HEIGHTS = {"scout": (0.7, 1.1), "harpoonist": (1.0, 1.7), "guardian": (0.9, 1.3),
           "dome_breaker": (0.9, 1.4), "abyss_admiral": (1.2, 1.8), "saboteur": (0.6, 1.0)}
MAX_WIDTH = 1.0


def declared(name):
    """The script run on a Model, with nothing built in Blender."""
    script = MODELS[name]
    model = Model(name, script.SEED, script.MATERIALS, atlas=script.ATLAS)
    script.build(model)
    return model


class UnitsTest(unittest.TestCase):
    def test_there_is_a_model_for_each_unit_type_of_the_game(self):
        with open(TYPES, encoding="utf-8") as file:
            values = re.search(r"enum Value \{([^}]*)\}", file.read()).group(1)
        self.assertEqual(sorted(UNITS), sorted(v.strip().lower() for v in values.split(",")))

    def test_each_is_a_unit_with_a_portrait_and_a_rig_node(self):
        for name in UNITS:
            with self.subTest(name):
                script = MODELS[name]
                self.assertEqual(script.FAMILY, "unit")
                self.assertTrue(script.PORTRAIT)
                self.assertIn("Rig", built(name)[1].paths)
                self.assertEqual(script.BUDGET.within(FAMILIES["unit"]), [])

    def test_each_has_the_four_actions_the_game_asks_for(self):
        for name in UNITS:
            with self.subTest(name):
                self.assertEqual(sorted(built(name)[1].animations),
                                 ["attack", "hit", "idle_loop", "swim_loop"])
                rig = declared(name).rig
                self.assertEqual({a.name: a.loop for a in rig.actions},
                                 {"idle": True, "swim": True, "attack": False, "hit": False})

    def test_each_skins_everything_to_its_skeleton_within_the_unit_caps(self):
        for name in UNITS:
            with self.subTest(name):
                report = built(name)[1]
                self.assertEqual(len(report.document["skins"]), 1)
                self.assertLessEqual(report.bones, FAMILIES["unit"].bones)
                self.assertLessEqual(report.keyframes, FAMILIES["unit"].keyframes)
                self.assertEqual(report.bones, len(declared(name).rig.bones))

    def test_each_attack_is_its_own_gesture_that_goes_further_than_a_breath(self):
        for name in UNITS:
            with self.subTest(name):
                actions = {a.name: a for a in declared(name).rig.actions}
                reach = lambda action: max(  # noqa: E731
                    max(abs(c) for key in keys for c in (*key.rotation, *key.location))
                    for keys in action.tracks.values())
                self.assertGreater(reach(actions["attack"]), 40)
                self.assertGreater(reach(actions["attack"]), 5 * reach(actions["idle"]))
                self.assertNotEqual(set(actions["attack"].tracks), set(actions["hit"].tracks))

    def test_each_stands_on_the_floor_at_the_size_of_its_role(self):
        for name in UNITS:
            with self.subTest(name):
                low, high = built(name)[1].bounds
                self.assertAlmostEqual(low[1], 0.0, delta=0.06)  # glTF y is up
                self.assertTrue(HEIGHTS[name][0] <= high[1] <= HEIGHTS[name][1], high[1])
                self.assertLessEqual(max(high[0] - low[0], high[2] - low[2]), MAX_WIDTH * 1.6)

    def test_the_army_is_told_apart_by_size(self):
        tops = {name: built(name)[1].bounds[1][1] for name in UNITS}
        self.assertGreater(tops["abyss_admiral"], tops["guardian"])
        self.assertLess(tops["scout"], tops["guardian"])
        self.assertLess(tops["saboteur"], tops["guardian"])

    def test_they_share_one_atlas_look_and_cost_a_few_triangles(self):
        for name in UNITS:
            with self.subTest(name):
                report = built(name)[1]
                self.assertEqual(report.draw_calls, 3)
                self.assertEqual(report.images, [(256, 256)])
                self.assertLess(report.triangles, 3_000)


if __name__ == "__main__":
    unittest.main()
