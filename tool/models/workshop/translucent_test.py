"""A translucent material (murk, mist): blended, double sided, its alpha the
fourth channel of the corners' colours that a paint gives."""

import unittest

from workshop import shapes
from workshop.materials import COLOR_ATTRIBUTE, Material
from workshop.model import Model
from workshop.occlusion import Occlusion
from workshop.scene import fresh_scene

MIST = Material("mist", 1.0, translucent=True)
ROCK = Material("rock", 0.9)


def _emit(paint):
    fresh_scene()
    model = Model("test", 3, [MIST, ROCK], Occlusion(strength={"mist": 0.0, "rock": 0.0}))
    model.add("Sea", shapes.box((1, 1, 1)), "mist", paint)
    model.add("Sea", shapes.box((1, 1, 1)).transform((3, 0, 0)), "rock", (0.5, 0.5, 0.5))
    return {obj.name: obj for obj in model.emit()}


class TranslucentTest(unittest.TestCase):
    def test_a_translucent_material_is_blended_and_seen_from_behind(self):
        material = _emit((0.5, 0.5, 0.5))["Sea_mist"].data.materials[0]
        self.assertEqual(material.surface_render_method, "BLENDED")
        self.assertFalse(material.use_backface_culling)
        self.assertNotEqual(_emit((0.5, 0.5, 0.5))["Sea_rock"].data.materials[0].surface_render_method,
                            "BLENDED")

    def test_a_paint_gives_the_alpha_of_each_corner(self):
        mist = _emit(lambda p, normal: (0.2, 0.3, 0.4, 0.25 if p.z > 0 else 0.75))["Sea_mist"].data
        alphas = {round(d.color[3], 2) for d in mist.color_attributes[COLOR_ATTRIBUTE].data}
        self.assertEqual(alphas, {0.25, 0.75})

    def test_a_paint_without_alpha_is_opaque(self):
        rock = _emit((0.5, 0.5, 0.5))["Sea_rock"].data
        self.assertEqual({d.color[3] for d in rock.color_attributes[COLOR_ATTRIBUTE].data}, {1.0})


if __name__ == "__main__":
    unittest.main()
