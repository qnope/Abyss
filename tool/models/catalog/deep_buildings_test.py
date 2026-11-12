"""Tests of the buildings of the descent (descent module, pressure capsule,
volcanic kernel): each is built in three tiers that add up, stands on its pad
within its footprint, and its crown stays under the headquarters'."""

import unittest

from catalog import MODELS
from catalog.base_island import layout
from catalog.buildings_test import SPILL, _boxes
from model_builds import built
from workshop import tiers

# Each building: the node its tier 3 holds for the game to animate.
BUILDINGS = {"descent_module": "Beacon", "pressure_capsule": "Beacon", "volcanic_kernel": "Flame"}


class DeepBuildingsTest(unittest.TestCase):
    def test_every_building_has_three_tiers_and_its_moving_node(self):
        for name, moving in BUILDINGS.items():
            with self.subTest(name):
                report = built(name)[1]
                self.assertTrue(tiers.has_tiers(report))
                for tier in tiers.TIERS:
                    self.assertIn(tier, report.paths)
                self.assertIn(f"Tier3/{moving}", report.paths)
                self.assertEqual(MODELS[name].NODES, [*tiers.TIERS, f"Tier3/{moving}"])

    def test_every_tier_adds_to_the_one_before_and_the_whole_is_within_the_budget(self):
        for name in BUILDINGS:
            with self.subTest(name):
                report = built(name)[1]
                (_, one, _), (_, two, _), (_, three, _) = tiers.stages(report)
                self.assertGreater(one, 1500)
                self.assertGreater(two, one * 1.25)
                self.assertGreater(three, two * 1.2)
                self.assertEqual(three, report.triangles)
                self.assertLessEqual(three, MODELS[name].BUDGET.triangles)

    def test_every_building_stands_on_its_pad_within_its_footprint(self):
        for name in BUILDINGS:
            with self.subTest(name):
                slot = next(s for s in layout.SLOTS if s.building == name)
                boxes = list(_boxes(built(name)[1]))
                self.assertAlmostEqual(min(low[1] for low, _ in boxes), 0.0, delta=0.06)
                for axis in (0, 2):
                    reach = max(max(abs(low[axis]), abs(high[axis])) for low, high in boxes)
                    self.assertLessEqual(reach, slot.footprint / 2 + SPILL)
                    self.assertGreater(reach, slot.footprint / 2 * 0.8)

    def test_no_building_rises_above_the_headquarters(self):
        headquarters = max(high[1] for _, high in _boxes(built("headquarters")[1]))
        for name in BUILDINGS:
            with self.subTest(name):
                top = max(high[1] for _, high in _boxes(built(name)[1]))
                self.assertLess(top, headquarters)
                self.assertGreater(top, 1.5)

    def test_each_tier_cuts_its_draw_calls_to_the_materials_it_uses(self):
        for name in BUILDINGS:
            with self.subTest(name):
                report = built(name)[1]
                for stage in tiers.stages(report):
                    self.assertLessEqual(stage[2], 11)


if __name__ == "__main__":
    unittest.main()
