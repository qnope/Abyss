"""Tests of the PNG writer: what it writes reads back the same, byte for byte
from one run to the next."""

import os
import tempfile
import unittest

import numpy

from workshop.png import read_png, write_png


def _pixels():
    rows = numpy.arange(12 * 7 * 3, dtype=numpy.uint32).reshape(7, 12, 3)
    return (rows * 37 % 256).astype(numpy.uint8)


class PngTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.path = os.path.join(self.folder.name, "atlas.png")

    def tearDown(self):
        self.folder.cleanup()

    def test_reads_back_what_it_wrote(self):
        write_png(self.path, _pixels())
        self.assertTrue(numpy.array_equal(read_png(self.path), _pixels()))

    def test_writes_the_same_bytes_twice(self):
        write_png(self.path, _pixels())
        first = open(self.path, "rb").read()
        write_png(self.path, _pixels())
        self.assertEqual(open(self.path, "rb").read(), first)

    def test_writes_an_rgb_png_of_the_pixels_size(self):
        write_png(self.path, _pixels())
        header = open(self.path, "rb").read(26)
        self.assertEqual(header[:8], b"\x89PNG\r\n\x1a\n")
        self.assertEqual(int.from_bytes(header[16:20], "big"), 12)
        self.assertEqual(int.from_bytes(header[20:24], "big"), 7)
        self.assertEqual(header[24:26], bytes((8, 2)))

    def test_refuses_anything_but_rgb_bytes(self):
        with self.assertRaises(ValueError):
            write_png(self.path, numpy.zeros((4, 4, 4), dtype=numpy.uint8))
        with self.assertRaises(ValueError):
            write_png(self.path, numpy.zeros((4, 4, 3), dtype=numpy.float32))


if __name__ == "__main__":
    unittest.main()
