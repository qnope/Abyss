"""Tests of the weight rules."""

import unittest

from workshop.skin import along, rigid


class SkinTest(unittest.TestCase):
    def test_a_rigid_part_belongs_to_one_bone(self):
        self.assertEqual(rigid("Body")((1, 2, 3)), {"Body": 1.0})

    def test_a_chain_blends_between_the_middles_of_neighbouring_bones(self):
        weights = along(["A", "B", "C"], [(0, 0, 0), (1, 0, 0), (2, 0, 0)])
        self.assertEqual(weights((0.5, 0, 0)), {"A": 0.5, "B": 0.5})
        self.assertEqual(weights((1.0, 3, 3)), {"A": 0.0, "B": 1.0})
        self.assertEqual(weights((1.75, 0, 0)), {"B": 0.25, "C": 0.75})

    def test_the_ends_of_a_chain_keep_the_end_bones(self):
        weights = along(["A", "B"], [(0, 0, 0), (0, 2, 0)])
        self.assertEqual(weights((0, -5, 0)), {"A": 1.0})
        self.assertEqual(weights((0, 9, 0)), {"B": 1.0})

    def test_weights_always_sum_to_one(self):
        weights = along(["A", "B", "C"], [(0, 0, 0), (1, 1, 0), (3, 2, 0)])
        for x in (-1, 0.2, 1.3, 2.5, 7):
            self.assertAlmostEqual(sum(weights((x, 0, 0)).values()), 1.0)

    def test_refuses_a_chain_that_does_not_go_forward(self):
        with self.assertRaises(ValueError):
            along(["A"], [(0, 0, 0)])
        with self.assertRaises(ValueError):
            along(["A", "B"], [(0, 0, 0), (0, 0, 0)])
        with self.assertRaises(ValueError):
            along(["A", "B", "C"], [(0, 0, 0), (2, 0, 0), (1, 0, 0)])


if __name__ == "__main__":
    unittest.main()
