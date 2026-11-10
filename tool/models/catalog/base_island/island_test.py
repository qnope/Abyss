"""Tests of the built island, in the glTF space the game reads (Y up): every
pad where its building stands in the Flutter game, as wide as its footprint
and flush on top, and a deck of 12 x 12 cells at the origin's height."""

import unittest

from catalog.base_island import layout
from model_builds import built

NAME = "base_island"


class IslandTest(unittest.TestCase):
    def test_puts_each_pad_at_the_centre_of_its_slot(self):
        report = built(NAME)[1]
        for slot in layout.SLOTS:
            with self.subTest(slot.node):
                x, y, z = report.translation(f"Pads/{slot.node}")
                self.assertAlmostEqual(x, slot.u - 6, places=4)
                self.assertAlmostEqual(y, layout.PAD_TOP, places=4)
                self.assertAlmostEqual(z, slot.v - 6, places=4)

    def test_gives_each_pad_its_footprint_and_a_flat_top_at_its_origin(self):
        report = built(NAME)[1]
        for slot in layout.SLOTS:
            with self.subTest(slot.node):
                low, high = report.bounds_of(f"Pads/{slot.node}")
                for axis in (0, 2):
                    self.assertLessEqual(high[axis] - low[axis], slot.footprint)
                    self.assertGreater(high[axis] - low[axis], slot.footprint - 0.2)
                self.assertAlmostEqual(high[1], 0, delta=0.005)
                self.assertLess(low[1], -layout.PAD_TOP)

    def test_lays_the_deck_over_the_twelve_cells_at_height_zero(self):
        low, high = built(NAME)[1].bounds_of("Island/Island_stone")
        for axis in (0, 2):
            self.assertAlmostEqual(low[axis], -layout.HALF, delta=0.15)
            self.assertAlmostEqual(high[axis], layout.HALF, delta=0.15)
        self.assertAlmostEqual(high[1], 0, delta=0.05)

    def test_hangs_the_island_below_the_deck(self):
        low, high = built(NAME)[1].bounds
        self.assertLess(low[1], -10)
        self.assertLess(high[1], 2)


if __name__ == "__main__":
    unittest.main()
