"""The seven monsters: rigged creatures of the monster family with the four
actions the game plays by name, a portrait for each family of the map (named as
the interface looks for it) and none for the Léviathan and the generic monster,
their own sizes, and the figures their scripts document."""

import os
import re
import unittest

from catalog import MODELS
from catalog.families import FAMILIES
from model_builds import built, rebuilt

FAMILY_NAMES = ["swarm", "armoured", "hunter", "colossus", "kraken"]
OTHERS = ["leviathan", "monster_generic"]
ALL = FAMILY_NAMES + OTHERS
ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


def _enum_names():
    """The lower-case values of MonsterFamily.Value, as the interface names portraits."""
    path = os.path.join(ROOT, "godot", "domain", "map", "monster_family.gd")
    with open(path, encoding="utf-8") as file:
        body = re.search(r"enum Value \{(.*?)\n\}", file.read(), re.S).group(1)
    return [m.lower() for m in re.findall(r"^\t([A-Z_]+),", body, re.M)]


class MonstersTest(unittest.TestCase):
    def test_the_portraits_are_the_families_the_interface_names(self):
        self.assertEqual(sorted(FAMILY_NAMES), sorted(_enum_names()))
        for name in FAMILY_NAMES:
            self.assertTrue(MODELS[name].PORTRAIT, name)
        for name in OTHERS:
            self.assertFalse(getattr(MODELS[name], "PORTRAIT", False), name)

    def test_each_is_a_monster_with_a_rig_and_the_four_actions(self):
        for name in ALL:
            with self.subTest(name):
                script, report = MODELS[name], built(name)[1]
                self.assertEqual(script.FAMILY, "monster")
                self.assertIn("Rig", report.paths)
                self.assertEqual(sorted(report.animations),
                                 ["attack", "hit", "idle_loop", "swim_loop"])
                self.assertGreaterEqual(report.bones, 5)

    def test_each_stays_within_the_monster_caps_and_its_own_budget(self):
        caps = FAMILIES["monster"]
        for name in ALL:
            with self.subTest(name):
                report = built(name)[1]
                self.assertEqual(MODELS[name].BUDGET.overruns(report), [])
                self.assertLessEqual(report.bones, caps.bones)
                self.assertLessEqual(report.keyframes, caps.keyframes)
                self.assertLessEqual(len(report.materials), caps.materials)
                self.assertEqual(report.images, [(512, 512)])

    def test_each_is_built_the_same_twice(self):
        for name in ALL:
            with self.subTest(name):
                self.assertEqual(rebuilt(name)[1].geometry_hash, built(name)[1].geometry_hash)

    def test_sizes_follow_the_story_of_the_game(self):
        """A fish of the swarm is smaller than a unit, a colossus much bigger, the
        Kraken and the Léviathan the biggest things of the game."""
        reach = {}
        for name in ALL:
            low, high = built(name)[1].bounds
            reach[name] = max(h - l for l, h in zip(low, high))
        self.assertLess(reach["swarm"], 0.8)
        self.assertGreater(reach["colossus"], 3.5)
        self.assertGreater(reach["kraken"], 6)
        self.assertGreater(reach["leviathan"], 8)
        self.assertEqual(max(reach, key=reach.get), "leviathan")
        self.assertLess(reach["swarm"], reach["monster_generic"])
        self.assertLess(reach["monster_generic"], reach["armoured"])

    def test_each_has_its_own_atlas_seed(self):
        seeds = [MODELS[name].SEED for name in ALL]
        self.assertEqual(len(set(seeds)), len(seeds))


if __name__ == "__main__":
    unittest.main()
