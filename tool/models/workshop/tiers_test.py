"""The tiers read from a glb: which node is one, what each costs, and what
the model shown up to a tier costs."""

import unittest

from workshop import tiers
from workshop.glb import GlbReport

# A building: a base mesh under no tier, a mesh under Tier1 and, under Tier2, a
# moving part drawn with two materials.
_DOCUMENT = {
    "scene": 0, "scenes": [{"nodes": [0]}],
    "nodes": [{"name": "Building", "children": [1, 2, 3]},
              {"name": "Tier1", "children": [4]},
              {"name": "Tier2", "children": [5]},
              {"name": "Base", "mesh": 0},
              {"name": "Tier1_hull", "mesh": 1},
              {"name": "Drone", "mesh": 2}],
    "meshes": [{"primitives": [{"attributes": {"POSITION": 0}, "indices": 3}]},
               {"primitives": [{"attributes": {"POSITION": 0}, "indices": 4}]},
               {"primitives": [{"attributes": {"POSITION": 0}, "indices": 5},
                               {"attributes": {"POSITION": 0}, "indices": 6}]}],
    "accessors": [{"count": 9}, {}, {}, {"count": 30}, {"count": 60}, {"count": 90}, {"count": 12}],
}


def _report(document=_DOCUMENT):
    return GlbReport(document, b"", "")


class TiersTest(unittest.TestCase):
    def test_a_tier_is_a_node_called_tier_and_a_number(self):
        self.assertEqual(tiers.tier_of("Tier3"), 3)
        for name in ("Tier", "Tiers", "Array", "Tier2_hull", "tier1"):
            self.assertEqual(tiers.tier_of(name), 0, name)

    def test_costs_what_each_tier_holds_itself(self):
        self.assertEqual(tiers.costs(_report()), {0: (10, 1), 1: (20, 1), 2: (34, 2)})

    def test_counts_the_tiers_of_the_model(self):
        self.assertEqual(tiers.count(_report()), 2)
        flat = dict(_DOCUMENT, nodes=[{"name": "Island", "mesh": 0}], scenes=[{"nodes": [0]}])
        self.assertEqual(tiers.count(_report(flat)), 0)
        self.assertEqual(tiers.shown(_report(flat)), [])

    def test_the_model_shown_up_to_a_tier_adds_the_tiers_and_the_base(self):
        self.assertEqual(tiers.shown(_report()), [(30, 2), (64, 4)])


if __name__ == "__main__":
    unittest.main()
