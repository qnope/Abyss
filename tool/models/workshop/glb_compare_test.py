"""Tests of the comparison of two glbs' geometry, within a float tolerance."""

import struct
import unittest

from workshop.glb import GlbReport
from workshop.glb_compare import geometry_differences


def _report(positions, indices=(0, 1, 2), count=None):
    """A glb report of one triangle: float positions, then ushort indices."""
    floats = struct.pack(f"<{len(positions)}f", *positions)
    shorts = struct.pack(f"<{len(indices)}H", *indices)
    document = {
        "bufferViews": [{"buffer": 0, "byteLength": len(floats)},
                        {"buffer": 0, "byteOffset": len(floats), "byteLength": len(shorts)}],
        "accessors": [
            {"bufferView": 0, "count": count or len(positions) // 3, "type": "VEC3",
             "componentType": 5126},
            {"bufferView": 1, "count": len(indices), "type": "SCALAR", "componentType": 5123},
        ],
    }
    return GlbReport(document, floats + shorts, ".")


def _colours(values):
    """A glb report of vertex colours: normalised ushorts, four per corner."""
    data = struct.pack(f"<{len(values)}H", *values)
    document = {"bufferViews": [{"buffer": 0, "byteLength": len(data)}],
                "accessors": [{"bufferView": 0, "count": len(values) // 4, "type": "VEC4",
                               "componentType": 5123, "normalized": True}]}
    return GlbReport(document, data, ".")


TRIANGLE = (0, 0, 0, 1, 0, 0, 0, 1, 0)
GREY = [30000] * 4000


class GlbCompareTest(unittest.TestCase):
    def test_the_same_geometry_has_no_difference(self):
        self.assertEqual(geometry_differences(_report(TRIANGLE), _report(TRIANGLE)), [])

    def test_floats_apart_by_less_than_the_tolerance_are_the_same(self):
        nudged = (0, 0, 0, 1.00001, 0, 0, 0, 1, 0)
        self.assertEqual(geometry_differences(_report(TRIANGLE), _report(nudged), 1e-4), [])

    def test_floats_apart_by_more_than_the_tolerance_are_named(self):
        moved = (0, 0, 0, 1.01, 0, 0, 0, 1, 0)
        differences = geometry_differences(_report(TRIANGLE), _report(moved), 1e-4)
        self.assertEqual(len(differences), 1)
        self.assertIn("accessor 0", differences[0])
        self.assertIn("1 of 9 values", differences[0])

    def test_integers_must_be_equal(self):
        flipped = _report(TRIANGLE, indices=(0, 2, 1))
        differences = geometry_differences(_report(TRIANGLE), flipped)
        self.assertEqual(len(differences), 1)
        self.assertIn("accessor 1", differences[0])

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
        shorter = _report(TRIANGLE[:6], indices=(0, 1, 0))
        differences = geometry_differences(_report(TRIANGLE), shorter)
        self.assertIn("accessor 0: 3 VEC3 against 2 VEC3", differences[0])

    def test_a_different_number_of_accessors_is_named(self):
        report = _report(TRIANGLE)
        fewer = GlbReport({"accessors": []}, b"", ".")
        self.assertEqual(geometry_differences(report, fewer), ["2 accessors against 0"])


if __name__ == "__main__":
    unittest.main()
