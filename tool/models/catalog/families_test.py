"""The budget of every script stays within the caps of its family."""

import unittest

from catalog import MODELS
from catalog.families import FAMILIES


class FamiliesTest(unittest.TestCase):
    def test_every_script_names_its_family(self):
        for name, script in MODELS.items():
            with self.subTest(name):
                self.assertIn(script.FAMILY, FAMILIES)

    def test_every_budget_stays_within_the_caps_of_its_family(self):
        for name, script in MODELS.items():
            with self.subTest(name):
                self.assertEqual(script.BUDGET.within(FAMILIES[script.FAMILY]), [])

    def test_only_the_families_that_move_have_bones(self):
        for family, caps in FAMILIES.items():
            with self.subTest(family):
                moves = family in ("unit", "monster")
                self.assertEqual(caps.bones > 0, moves)
                self.assertEqual(caps.keyframes > 0, moves)

    def test_the_buildings_caps_are_the_prototypes_largest(self):
        caps = FAMILIES["building"]
        self.assertEqual((caps.triangles, caps.materials, caps.texture_px), (20_000, 5, 1024))

    def test_a_creature_costs_less_than_a_building_and_a_boss_more_than_a_unit(self):
        order = [FAMILIES[f].triangles for f in ("unit", "monster", "building")]
        self.assertEqual(order, sorted(order))


if __name__ == "__main__":
    unittest.main()
