"""Tests of the seeded scatter of decor."""

import math
import random
import unittest

from workshop.scatter import scatter


def _square(rng):
    return (rng.uniform(0, 10), rng.uniform(0, 10))


class ScatterTest(unittest.TestCase):
    def test_gives_the_same_points_for_the_same_seed(self):
        one = scatter(random.Random(4), _square, count=30, spacing=0.8)
        two = scatter(random.Random(4), _square, count=30, spacing=0.8)
        self.assertEqual(one, two)
        self.assertNotEqual(one, scatter(random.Random(5), _square, count=30, spacing=0.8))

    def test_keeps_the_points_apart(self):
        points = scatter(random.Random(1), _square, count=40, spacing=1.0)
        self.assertEqual(len(points), 40)
        for i, a in enumerate(points):
            for b in points[i + 1:]:
                self.assertGreaterEqual(math.dist(a, b), 1.0)

    def test_never_places_a_point_where_it_is_not_allowed(self):
        points = scatter(random.Random(2), _square, count=20, spacing=0.5,
                         allowed=lambda p: p[0] > 5)
        self.assertTrue(all(p[0] > 5 for p in points))

    def test_stops_short_when_the_room_runs_out(self):
        points = scatter(random.Random(3), _square, count=500, spacing=3.0)
        self.assertLess(len(points), 30)

    def test_keeps_away_from_points_already_placed(self):
        points = scatter(random.Random(3), _square, count=20, spacing=1.0, taken=[(5, 5)])
        self.assertTrue(all(math.dist(p, (5, 5)) >= 1.0 for p in points))


if __name__ == "__main__":
    unittest.main()
