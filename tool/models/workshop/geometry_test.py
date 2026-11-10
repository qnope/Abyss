"""Tests of the geometry's own operations. Needs bpy."""

import unittest

from workshop import shapes


class GeometryTest(unittest.TestCase):
    def test_subdivides_the_long_edges_keeping_the_shape_and_its_shading(self):
        box = shapes.box((2, 0.5, 1), smooth=True)
        box.subdivide(0.6)
        low, high = box.bounds()
        self.assertEqual((tuple(low), tuple(high)), ((-1, -0.25, 0), (1, 0.25, 1)))
        self.assertGreater(len(box.faces), 6 * 4)
        self.assertTrue(all(box.smooth))
        lengths = [(box.verts[a] - box.verts[b]).length for f in box.faces
                   for a, b in zip(f, f[1:] + f[:1])]
        self.assertLessEqual(max(lengths), 0.6)


if __name__ == "__main__":
    unittest.main()
