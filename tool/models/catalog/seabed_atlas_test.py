"""The atlases of the map's floors: 512 px, a lit tile for each variant and a
dim one for the fog, every one fading to the same plain shade on its border,
so that any two meet turned by any quarter."""

import unittest

import numpy

from catalog.textures import seabed
from workshop.canvas import Canvas

LOOKS = {"caustics": {"ripple": (2, 1), "ripple_depth": 0.05, "detail": "caustics", "seed": 1},
         "flecks": {"ripple": (1, 3), "ripple_depth": 0.04, "detail": "flecks", "seed": 2},
         "ash": {"ripple": (3, 2), "ripple_depth": 0.03, "detail": "ash", "seed": 3}}


def _border(shade):
    return numpy.concatenate([shade[0], shade[-1], shade[:, 0], shade[:, -1]])


class SeabedAtlasTest(unittest.TestCase):
    def test_every_atlas_is_512_with_a_tile_for_each_variant_the_fog_and_white(self):
        for name, look in LOOKS.items():
            with self.subTest(name):
                atlas = seabed.atlas_of(look)
                self.assertEqual(atlas.size, 512)
                self.assertEqual(sorted(atlas.tiles), ["fog1", "fog2", "lit1", "lit2", "lit3", "plain"])
                self.assertEqual(atlas.pixels().shape, (512, 512, 3))

    def test_every_tile_fades_to_one_plain_shade_on_its_border(self):
        for name, look in LOOKS.items():
            borders = []
            for k in range(3):
                for hidden in (False, True):
                    canvas = Canvas(128, 128, k + 1)
                    shade = numpy.asarray(seabed.painter(look, k, hidden)(canvas))
                    borders.append(_border(shade[1:-1, 1:-1]))
            with self.subTest(name):
                low, high = min(b.min() for b in borders[::2]), max(b.max() for b in borders[::2])
                self.assertLess(high - low, 0.02)

    def test_the_fog_tile_is_the_shared_grain_alone_and_dimmer(self):
        for name, look in LOOKS.items():
            canvas = Canvas(128, 128, 1)
            lit, hidden = seabed.painter(look, 0)(canvas), seabed.painter(look, 0, True)(canvas)
            with self.subTest(name):
                self.assertLess(hidden.mean(), lit.mean() + 0.02)
                self.assertGreater(abs(lit - hidden).max(), 0.01)

    def test_every_variant_of_a_level_differs(self):
        for name, look in LOOKS.items():
            canvas = Canvas(128, 128, 5)
            shades = [seabed.painter(look, k)(canvas) for k in range(3)]
            with self.subTest(name):
                self.assertFalse(numpy.allclose(shades[0], shades[1]))
                self.assertFalse(numpy.allclose(shades[1], shades[2]))


if __name__ == "__main__":
    unittest.main()
