"""Tests of the atlas: where its tiles lie, what it paints and how a face's
corners are mapped into a tile. Needs bpy for the geometry."""

import os
import tempfile
import unittest

import numpy

from workshop import shapes
from workshop.atlas import GUTTER, Atlas, Tile
from workshop.geometry import Geometry
from workshop.png import read_png


def _white(canvas):
    return numpy.ones((canvas.height, canvas.width, 3))


def _ramp(canvas):
    return numpy.dstack([canvas.s, canvas.t, numpy.zeros_like(canvas.s)])


def _atlas():
    return Atlas(256, 4, {"plain": Tile((0, 0, 1, 1), _white), "ramp": Tile((1, 0, 2, 1), _ramp),
                          "noise": Tile((0, 1, 2, 2), lambda c: c.fbm(2)[..., None] * 0.2 + 0.5,
                                        seamless=True)})


def _quad(x0, x1):
    """A quad facing -y (towards the front view) from x0 to x1, 1 high."""
    return Geometry([(x0, 0, 0), (x1, 0, 0), (x1, 0, 1), (x0, 0, 1)], [(0, 1, 2, 3)])


class AtlasTest(unittest.TestCase):
    def test_places_a_tile_by_its_cells_from_the_top_left_inside_a_gutter(self):
        g = GUTTER / 256
        u0, v0, u1, v1 = _atlas().rect("ramp")
        self.assertAlmostEqual(u0, 0.25 + g)
        self.assertAlmostEqual(u1, 0.75 - g)
        self.assertAlmostEqual(v0, 0.75 + g)
        self.assertAlmostEqual(v1, 1.0 - g)

    def test_fits_a_face_to_the_whole_tile_upright(self):
        atlas = _atlas()
        u0, v0, u1, v1 = atlas.rect("ramp")
        corners = atlas.fit("ramp")(_quad(2, 3))[0]
        self.assertEqual([tuple(round(c, 6) for c in uv) for uv in corners],
                         [(round(u, 6), round(v, 6)) for u, v in
                          ((u0, v0), (u1, v0), (u1, v1), (u0, v1))])

    def test_fits_the_faces_of_one_flat_side_together(self):
        atlas = _atlas()
        u0, _, u1, _ = atlas.rect("ramp")
        uvs = atlas.fit("ramp")(_quad(0, 1).extend(_quad(1, 2)))
        self.assertAlmostEqual(uvs[0][1][0], (u0 + u1) / 2)
        self.assertAlmostEqual(uvs[1][1][0], u1)

    def test_fits_a_face_lying_flat_with_y_up(self):
        atlas = _atlas()
        top = shapes.box((1, 2, 1), bottom=False)
        uvs = atlas.fit("ramp")(top)
        index = next(i for i in range(len(top.faces)) if top.face_normal(i).z > 0.9)
        u0, v0, _, v1 = atlas.rect("ramp")
        by_corner = {tuple(top.verts[i]): uv for i, uv in zip(top.faces[index], uvs[index])}
        self.assertAlmostEqual(by_corner[(-0.5, -1.0, 1.0)][0], u0)
        self.assertAlmostEqual(by_corner[(-0.5, -1.0, 1.0)][1], v0)
        self.assertAlmostEqual(by_corner[(-0.5, 1.0, 1.0)][1], v1)

    def test_maps_a_whole_geometry_on_a_plane(self):
        atlas = _atlas()
        u0, v0, u1, v1 = atlas.rect("ramp")
        both = _quad(0, 1).extend(_quad(1, 2))
        uvs = atlas.planar("ramp", (1, 0, 0), (0, 0, 1))(both)
        self.assertAlmostEqual(uvs[0][1][0], (u0 + u1) / 2)
        self.assertAlmostEqual(uvs[1][1][0], u1)

    def test_tiles_a_seamless_tile_across_neighbouring_faces(self):
        atlas = _atlas()
        uvs = atlas.tiled("noise", period=1.0)(_quad(0.2, 0.7).extend(_quad(0.7, 1.4)))
        self.assertEqual(uvs[0][1], uvs[1][0])
        self.assertEqual(uvs[0][2], uvs[1][3])
        u0, v0, u1, v1 = atlas.rect("noise")
        for face in uvs:
            for u, v in face:
                self.assertTrue(u0 - 1e-9 <= u <= u1 + 1e-9 and v0 - 1e-9 <= v <= v1 + 1e-9)

    def test_refuses_to_tile_a_tile_painted_once(self):
        with self.assertRaises(ValueError):
            _atlas().tiled("ramp", period=1.0)

    def test_maps_every_corner_of_a_solid_face_to_the_tiles_centre(self):
        atlas = _atlas()
        u0, v0, u1, v1 = atlas.rect("plain")
        self.assertEqual(atlas.solid("plain")(_quad(0, 1)), [[((u0 + u1) / 2, (v0 + v1) / 2)] * 4])
        self.assertEqual(atlas.blank(_quad(0, 1)), atlas.solid("plain")(_quad(0, 1)))

    def test_paints_each_tile_and_extends_it_into_its_gutter(self):
        pixels = _atlas().pixels()
        self.assertEqual(pixels.shape, (256, 256, 3))
        self.assertTrue(numpy.all(pixels[0:64, 0:64] == 255))
        ramp = pixels[0:64, 64:192]
        self.assertTrue(numpy.array_equal(ramp[:, 0], ramp[:, GUTTER]))
        self.assertGreater(int(ramp[GUTTER, -GUTTER - 1, 0]), int(ramp[GUTTER, GUTTER, 0]) + 200)
        self.assertGreater(int(ramp[GUTTER, GUTTER, 1]), int(ramp[-GUTTER - 1, GUTTER, 1]) + 200)

    def test_repeats_a_seamless_tile_two_by_two(self):
        noise = _atlas().pixels()[64 + GUTTER:192 - GUTTER, GUTTER:128 - GUTTER]
        half = noise.shape[1] // 2
        self.assertTrue(numpy.array_equal(noise[:, :half], noise[:, half:]))
        self.assertTrue(numpy.array_equal(noise[:half], noise[half:]))

    def test_writes_its_pixels_as_a_png(self):
        with tempfile.TemporaryDirectory() as folder:
            path = os.path.join(folder, "atlas.png")
            _atlas().write(path)
            self.assertTrue(numpy.array_equal(read_png(path), _atlas().pixels()))

    def test_refuses_a_bad_layout(self):
        plain = Tile((0, 0, 1, 1), _white)
        with self.assertRaises(ValueError):
            Atlas(300, 4, {"plain": plain})
        with self.assertRaises(ValueError):
            Atlas(256, 4, {"ramp": Tile((0, 0, 1, 1), _ramp)})
        with self.assertRaises(ValueError):
            Atlas(256, 4, {"plain": plain, "out": Tile((3, 3, 2, 1), _ramp)})
        with self.assertRaises(ValueError):
            Atlas(256, 4, {"plain": plain, "over": Tile((0, 0, 2, 1), _ramp)})


if __name__ == "__main__":
    unittest.main()
