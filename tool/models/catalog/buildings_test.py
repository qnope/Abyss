"""Tests of the built buildings, in the glTF space the game reads (Y up):
each stands on its pad, its origin at the pad's centre on its top, within
its footprint (the reef may spill a little over the edge), and its moving
parts are nodes of their own on its axis."""

import unittest

from catalog.base_island import layout
from model_builds import built

# Each building: its slot on the island, and its nodes the game moves.
BUILDINGS = {"headquarters": ("Headquarters", ["Beacon", "Dish"]),
             "solar_panel": ("SolarPanel", ["Array"]),
             "coral_citadel": ("CoralCitadel", ["Heart"]),
             "algae_farm": ("AlgaeFarm", ["Tier2/Drone"]),
             "coral_mine": ("CoralMine", ["Tier1/Wheel", "Tier3/CrownWheel"]),
             "ore_extractor": ("OreExtractor", ["Tier1/Drill"])}
SPILL = 0.3  # how far the reef at a building's foot may reach past its pad


def _boxes(report):
    """The box of every mesh node, moved by the nodes above it."""
    for path in report.paths:
        try:
            low, high = report.bounds_of(path)
        except KeyError:
            continue
        parts = path.split("/")
        shift = [sum(report.translation("/".join(parts[:k + 1]))[a] for k in range(len(parts)))
                 for a in range(3)]
        yield [l + s for l, s in zip(low, shift)], [h + s for h, s in zip(high, shift)]


class BuildingsTest(unittest.TestCase):
    def test_every_building_stands_within_its_footprint(self):
        for name, (node, _) in BUILDINGS.items():
            with self.subTest(name):
                slot = next(s for s in layout.SLOTS if s.node == node)
                boxes = list(_boxes(built(name)[1]))
                for axis in (0, 2):
                    reach = max(max(abs(low[axis]), abs(high[axis])) for low, high in boxes)
                    self.assertLessEqual(reach, slot.footprint / 2 + SPILL)
                    self.assertGreater(reach, slot.footprint / 2 * 0.8)

    def test_every_building_stands_on_the_pads_top(self):
        for name in BUILDINGS:
            with self.subTest(name):
                lowest = min(low[1] for low, _ in _boxes(built(name)[1]))
                self.assertAlmostEqual(lowest, 0.0, delta=0.06)

    def test_every_moving_part_is_a_node_on_the_buildings_axis(self):
        for name, (node, moving) in BUILDINGS.items():
            report = built(name)[1]
            for part in moving:
                with self.subTest(f"{name}/{part}"):
                    self.assertIn(f"{node}/{part}", report.paths)
                    self.assertGreater(report.translation(f"{node}/{part}")[1], 0.3)
                    self.assertGreater(report.triangles_under(f"{node}/{part}"), 20)

    def test_the_headquarters_stands_tallest(self):
        tops = {name: max(high[1] for _, high in _boxes(built(name)[1])) for name in BUILDINGS}
        self.assertEqual(max(tops, key=tops.get), "headquarters")
        self.assertGreater(tops["headquarters"], 2.5)


if __name__ == "__main__":
    unittest.main()
