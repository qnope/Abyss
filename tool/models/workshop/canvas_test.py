"""Tests of the canvas the atlas tiles are painted on: its coordinates, its
noise, seamless when asked, and its shapes."""

import unittest

import numpy

from workshop.canvas import Canvas


class CanvasTest(unittest.TestCase):
    def test_gives_pixel_centres_with_t_going_up(self):
        canvas = Canvas(4, 2, seed=1)
        self.assertEqual(canvas.s.shape, (2, 4))
        self.assertAlmostEqual(canvas.s[0, 0], 0.125)
        self.assertAlmostEqual(canvas.t[0, 0], 0.75)
        self.assertAlmostEqual(canvas.t[1, 0], 0.25)
        self.assertAlmostEqual(canvas.x[0, 3], 3.5)
        self.assertAlmostEqual(canvas.y[1, 0], 0.5)

    def test_paints_the_same_noise_for_the_same_seed(self):
        a, b, c = Canvas(32, 32, 7), Canvas(32, 32, 7), Canvas(32, 32, 8)
        self.assertTrue(numpy.array_equal(a.noise(4), b.noise(4)))
        self.assertFalse(numpy.array_equal(a.noise(4), c.noise(4)))

    def test_keeps_its_noise_in_minus_one_to_one(self):
        canvas = Canvas(64, 32, 3)
        for field in (canvas.noise(5), canvas.fbm(3, octaves=4), canvas.cells(6)):
            self.assertGreaterEqual(field.min(), -1.0001)
            self.assertLessEqual(field.max(), 1.0001)
            self.assertGreater(field.std(), 0.05)

    def test_wraps_its_noise_around_its_edges(self):
        canvas = Canvas(64, 64, 5)
        for field in (canvas.fbm(4, octaves=3), canvas.cells(5), canvas.cracks(5)):
            inner = numpy.abs(numpy.diff(field, axis=1)).max()
            seam = numpy.abs(field[:, 0] - field[:, -1]).max()
            self.assertLessEqual(seam, inner * 1.5)
            seam_rows = numpy.abs(field[0, :] - field[-1, :]).max()
            self.assertLessEqual(seam_rows, numpy.abs(numpy.diff(field, axis=0)).max() * 1.5)

    def test_draws_soft_boxes_and_discs_in_pixels(self):
        canvas = Canvas(20, 20, 1)
        box = canvas.box(5, 5, 15, 15)
        self.assertEqual(box[10, 10], 1.0)
        self.assertEqual(box[1, 1], 0.0)
        disc = canvas.disc(10, 10, 3)
        self.assertEqual(disc[10, 10], 1.0)
        self.assertEqual(disc[10, 16], 0.0)
        self.assertGreater(disc[10, 12], 0.5)

    def test_gives_a_random_generator_of_its_seed(self):
        self.assertEqual(Canvas(2, 2, 9).rng.random(), Canvas(2, 2, 9).rng.random())


if __name__ == "__main__":
    unittest.main()
