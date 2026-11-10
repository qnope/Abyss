"""Tests of the Model: how it joins static parts, keeps pieces apart and
shades them. Needs bpy."""

import unittest

from workshop import shapes
from workshop.materials import COLOR_ATTRIBUTE, Material
from workshop.model import Model
from workshop.scene import fresh_scene

ROCK, GLOW = Material("rock", 0.9), Material("glow", 0.4, emission="#00ffff")
GREY = (0.5, 0.5, 0.5)


def _model():
    fresh_scene()
    model = Model("test", 3, [ROCK, GLOW])
    floor = shapes.box((4, 4, 0.1)).transform((0, 0, -0.1))
    model.add("Island", floor, "rock", GREY)
    model.add("Island", shapes.box((1, 1, 1)).transform((1.5, 1.5, 0)), "rock", GREY)
    model.add("Island", shapes.octahedron(0.1).transform((0, 1, 0.2)), "glow", GREY)
    pad = model.piece("Pads/One", (-1, 0, 0))
    pad.add(shapes.box((0.5, 0.5, 0.1)), "rock", GREY)
    pad.add(shapes.octahedron(0.05), "glow", GREY)
    return model


class ModelTest(unittest.TestCase):
    def test_joins_the_static_parts_of_a_group_per_material(self):
        objects = {obj.name: obj for obj in _model().emit()}
        self.assertEqual(sorted(objects), ["Island_glow", "Island_rock", "One"])
        self.assertEqual(objects["Island_rock"].parent.name, "Island")
        self.assertEqual(len(objects["Island_rock"].data.polygons), 12)

    def test_keeps_a_piece_apart_at_its_location_with_all_its_materials(self):
        objects = {obj.name: obj for obj in _model().emit()}
        piece = objects["One"]
        self.assertEqual(piece.parent.name, "Pads")
        self.assertEqual(tuple(piece.location), (-1, 0, 0))
        self.assertEqual([m.name for m in piece.data.materials], ["rock", "glow"])

    def test_counts_its_triangles(self):
        self.assertEqual(_model().triangles, 12 * 3 + 8 * 2)

    def test_darkens_the_corners_the_model_hides(self):
        floor = next(obj for obj in _model().emit() if obj.name == "Island_rock").data
        colors = floor.color_attributes[COLOR_ATTRIBUTE].data

        def red_on_top_at(x, y):
            return [colors[loop].color[0] for polygon in floor.polygons
                    if polygon.normal.z > 0.99 for loop in polygon.loop_indices
                    if tuple(floor.vertices[floor.loops[loop].vertex_index].co) == (x, y, 0)]

        open_corner, hidden_corner = red_on_top_at(-2, -2), red_on_top_at(2, 2)
        self.assertEqual(len(open_corner), 1)
        self.assertGreater(open_corner[0], 0.2)
        self.assertLess(hidden_corner[0], open_corner[0] * 0.8)

    def test_refuses_a_material_it_does_not_have(self):
        with self.assertRaises(KeyError):
            _model().add("Island", shapes.octahedron(1), "coral", GREY)


if __name__ == "__main__":
    unittest.main()
