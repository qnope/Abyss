"""Tests of the comparison of two glbs' geometry, within a float tolerance."""

import unittest

from workshop.fake_glb import FakeGlb
from workshop.glb_compare import geometry_differences

TRIANGLE = (0, 0, 0, 1, 0, 0, 0, 1, 0)
GREY = [30000] * 4000
IDENTITY = (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)


def _triangle(positions=TRIANGLE, indices=(0, 1, 2)):
    """One mesh of one triangle: float positions, then ushort indices."""
    glb = FakeGlb()
    glb.mesh({"POSITION": glb.floats(positions), "indices": glb.ushorts(indices)})
    return glb.report()


def _colours(values):
    """One mesh whose vertex colours are normalised ushorts, four per corner."""
    glb = FakeGlb()
    glb.mesh({"COLOR_0": glb.ushorts(values, "VEC4", normalized=True)})
    return glb.report()


def _two_triangles(shared):
    """Two meshes of the same triangle, on one accessor when [shared]."""
    glb = FakeGlb()
    first = glb.floats(TRIANGLE)
    glb.mesh({"POSITION": first})
    glb.mesh({"POSITION": first if shared else glb.floats(TRIANGLE)})
    return glb.report()


def _two_skins(shared):
    """Two skins of the same inverse bind matrix, on one accessor when [shared]."""
    glb = FakeGlb()
    first = glb.floats(IDENTITY, "MAT4")
    glb.skin(first)
    glb.skin(first if shared else glb.floats(IDENTITY, "MAT4"))
    return glb.report()


class GlbCompareTest(unittest.TestCase):
    def test_the_same_geometry_has_no_difference(self):
        self.assertEqual(geometry_differences(_triangle(), _triangle()), [])

    def test_floats_apart_by_less_than_the_tolerance_are_the_same(self):
        nudged = (0, 0, 0, 1.00001, 0, 0, 0, 1, 0)
        self.assertEqual(geometry_differences(_triangle(), _triangle(nudged), 1e-4), [])

    def test_floats_apart_by_more_than_the_tolerance_are_named(self):
        moved = (0, 0, 0, 1.01, 0, 0, 0, 1, 0)
        differences = geometry_differences(_triangle(), _triangle(moved), 1e-4)
        self.assertEqual(len(differences), 1)
        self.assertIn("mesh 0 primitive 0 POSITION", differences[0])
        self.assertIn("1 of 9 values", differences[0])

    def test_integers_must_be_equal(self):
        differences = geometry_differences(_triangle(), _triangle(indices=(0, 2, 1)))
        self.assertEqual(differences, ["mesh 0 primitive 0 indices: 2 of 3 values differ, "
                                       "by up to 1"])

    def test_a_rare_flipped_occlusion_ray_in_the_colours_is_the_same(self):
        flipped = list(GREY)
        flipped[7] += 417
        flipped[900] -= 153
        self.assertEqual(geometry_differences(_colours(GREY), _colours(flipped)), [])

    def test_a_colour_further_than_one_occlusion_ray_is_named(self):
        repainted = list(GREY)
        repainted[7] += 6000
        differences = geometry_differences(_colours(GREY), _colours(repainted))
        self.assertIn("1 of 4000 values differ", differences[0])

    def test_many_slightly_different_colours_are_named(self):
        shifted = [value + 300 for value in GREY]
        differences = geometry_differences(_colours(GREY), _colours(shifted))
        self.assertIn("4000 of 4000 values differ", differences[0])

    def test_a_different_layout_is_named(self):
        shorter = _triangle(TRIANGLE[:6], indices=(0, 1, 0))
        differences = geometry_differences(_triangle(), shorter)
        self.assertIn("mesh 0 primitive 0 POSITION: 3 VEC3 against 2 VEC3", differences[0])

    def test_a_missing_mesh_is_named(self):
        nothing = FakeGlb().report()
        self.assertEqual(geometry_differences(_triangle(), nothing),
                         ["mesh 0 primitive 0 POSITION: missing",
                          "mesh 0 primitive 0 indices: missing"])
        self.assertEqual(geometry_differences(nothing, _triangle())[0],
                         "mesh 0 primitive 0 POSITION: unexpected")

    def test_an_accessor_shared_by_two_meshes_is_the_same_as_two_copies(self):
        # The exporter writes data equal to the last bit once: whether two
        # meshes share an accessor depends on the machine's last bits.
        self.assertEqual(geometry_differences(_two_triangles(True), _two_triangles(False)), [])

    def test_the_inverse_binds_of_the_skins_are_compared(self):
        self.assertEqual(geometry_differences(_two_skins(True), _two_skins(False)), [])
        glb = FakeGlb()
        glb.skin(glb.floats((2,) + IDENTITY[1:], "MAT4"))
        glb.skin(glb.floats(IDENTITY, "MAT4"))
        self.assertEqual(geometry_differences(_two_skins(True), glb.report()),
                         ["skin 0 inverse binds: 1 of 16 values differ, by up to 1"])


if __name__ == "__main__":
    unittest.main()
