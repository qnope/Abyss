"""Tests of the rampart's line: in the band the island keeps for it, closed
at the corners and open at every gate, wide enough for the walkways."""

import math
import random
import unittest

from catalog.base_island import layout
from catalog.base_rampart import ring


def _distance_to(point, start, end):
    dx, dy = end[0] - start[0], end[1] - start[1]
    t = max(0.0, min(1.0, ((point[0] - start[0]) * dx + (point[1] - start[1]) * dy)
                     / (dx * dx + dy * dy)))
    return math.dist(point, (start[0] + t * dx, start[1] + t * dy))


class RingTest(unittest.TestCase):
    def test_stands_in_the_band_beyond_the_deck(self):
        inner = ring.RADIUS - ring.THICKNESS / 2 - layout.HALF
        outer = ring.RADIUS + ring.THICKNESS / 2 - layout.HALF
        self.assertGreaterEqual(inner, layout.RAMPART_FROM)
        self.assertLessEqual(outer, layout.RAMPART_TO)

    def test_opens_at_every_gate_wider_than_a_walkway(self):
        runs = ring.runs()
        for gate in ring.gates():
            with self.subTest(gate):
                clearance = min(_distance_to(gate, *run) for run in runs)
                self.assertAlmostEqual(clearance, ring.GAP)
                self.assertGreater(clearance, layout.WALKWAY_WIDTH)

    def test_closes_the_ring_elsewhere(self):
        total = sum(math.dist(*run) for run in ring.runs())
        self.assertAlmostEqual(total, 8 * ring.RADIUS - 4 * 2 * ring.GAP)
        self.assertEqual(len(ring.runs()), 8)

    def test_gives_two_ends_at_each_gate_facing_it(self):
        ends = ring.gate_ends()
        self.assertEqual(len(ends), 8)
        for point, (dx, dy) in ends:
            gate = min(ring.gates(), key=lambda g: math.dist(g, point))
            ahead = (point[0] + dx * ring.GAP, point[1] + dy * ring.GAP)
            self.assertAlmostEqual(math.dist(ahead, gate), 0)

    def test_cuts_a_run_into_stones_end_to_end(self):
        start, end = ring.runs()[0]
        stones = ring.blocks(start, end, random.Random(3), 0.4, 0.7)
        self.assertAlmostEqual(sum(size for _, size in stones), math.dist(start, end))
        for _, size in stones[:-1]:
            self.assertGreaterEqual(size, 0.4)
        self.assertLessEqual(max(size for _, size in stones), 1.4)


if __name__ == "__main__":
    unittest.main()
