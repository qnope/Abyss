"""The four production buildings: each grows in three tiers that add up, with
its moving parts in the nodes the game finds, and its tiers' cost stays in
its budget."""

import unittest

from catalog import MODELS
from model_builds import built, rebuilt
from workshop import tiers

# Each building: its root, its signature material and its moving parts.
PRODUCTION = {"algae_farm": ("AlgaeFarm", "algae", ["Tier2/Drone"]),
              "coral_mine": ("CoralMine", "lamp", ["Tier1/Wheel", "Tier3/CrownWheel"]),
              "ore_extractor": ("OreExtractor", "lamp", ["Tier1/Drill"]),
              "solar_panel": ("SolarPanel", "lamp", ["Array"])}


class ProductionTest(unittest.TestCase):
    def test_every_building_has_its_three_tiers_as_nodes_of_its_own(self):
        for name, (root, _, _) in PRODUCTION.items():
            with self.subTest(name):
                report = built(name)[1]
                for tier in (1, 2, 3):
                    self.assertIn(f"{root}/Tier{tier}", report.paths)
                self.assertIn(root, MODELS[name].NODES)
                self.assertEqual(MODELS[name].TIERS, [f"{root}/Tier{k}" for k in (1, 2, 3)])

    def test_every_tier_adds_to_the_ones_below_it(self):
        for name in PRODUCTION:
            with self.subTest(name):
                report = built(name)[1]
                self.assertEqual(tiers.count(report), 3)
                self.assertLessEqual({1, 2, 3}, set(tiers.costs(report)))
                shown = tiers.shown(report)
                for lower, higher in zip(shown, shown[1:]):
                    self.assertGreater(higher[0], lower[0])
                    self.assertGreater(higher[1], lower[1])
                self.assertEqual(shown[-1][0], report.triangles)

    def test_no_tier_is_left_nearly_empty(self):
        for name in PRODUCTION:
            with self.subTest(name):
                costs = tiers.costs(built(name)[1])
                for tier in (1, 2, 3):
                    self.assertGreater(costs[tier][0], 150, f"tier {tier}")
                self.assertGreater(costs[1][0], costs[3][0])

    def test_every_building_is_dressed_in_its_signature_light(self):
        for name, (_, material, _) in PRODUCTION.items():
            with self.subTest(name):
                self.assertIn(material, built(name)[1].materials)

    def test_moving_parts_hold_meshes_of_their_own(self):
        for name, (root, _, parts) in PRODUCTION.items():
            for part in parts:
                with self.subTest(f"{name}/{part}"):
                    self.assertGreater(built(name)[1].triangles_under(f"{root}/{part}"), 20)

    def test_a_building_builds_the_same_twice(self):
        for name in PRODUCTION:
            with self.subTest(name):
                self.assertEqual(rebuilt(name)[1].triangles, built(name)[1].triangles)

    def test_every_building_has_a_portrait_and_is_a_building(self):
        for name in PRODUCTION:
            self.assertTrue(MODELS[name].PORTRAIT)
            self.assertEqual(MODELS[name].FAMILY, "building")


if __name__ == "__main__":
    unittest.main()
