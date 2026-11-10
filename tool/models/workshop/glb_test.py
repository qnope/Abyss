"""Tests of the glb reader, on files written here with the stdlib."""

import json
import os
import struct
import tempfile
import unittest

from workshop.glb import read_glb


def _glb(document, binary=b""):
    """The bytes of a glb holding the JSON [document] and the [binary] chunk."""
    text = json.dumps(document).encode()
    text += b" " * (-len(text) % 4)
    binary += b"\0" * (-len(binary) % 4)
    chunks = struct.pack("<II", len(text), 0x4E4F534A) + text
    if binary:
        chunks += struct.pack("<II", len(binary), 0x004E4942) + binary
    return struct.pack("<III", 0x46546C67, 2, 12 + len(chunks)) + chunks


def _png_header(width, height):
    return b"\x89PNG\r\n\x1a\n" + struct.pack(">I4sII", 13, b"IHDR", width, height) + b"\0" * 9


# Two nodes share a mesh of two primitives: 4 and 2 triangles.
DOCUMENT = {
    "asset": {"version": "2.0"},
    "scene": 0,
    "scenes": [{"nodes": [0, 3]}],
    "nodes": [
        {"name": "Island", "children": [1, 2]},
        {"name": "Rock", "mesh": 0},
        {"name": "Copy", "mesh": 0, "translation": [1, 2, 3]},
        {"name": "Pads"},
    ],
    "meshes": [{"primitives": [
        {"attributes": {"POSITION": 0}, "indices": 1, "material": 0},
        {"attributes": {"POSITION": 0}, "material": 1},
    ]}],
    "accessors": [
        {"count": 6, "type": "VEC3", "componentType": 5126,
         "min": [-1, -2, -3], "max": [1, 2, 3]},
        {"count": 12, "type": "SCALAR", "componentType": 5123},
    ],
    "materials": [{"name": "rock"}, {"name": "glow"}],
}


class GlbTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)

    def write(self, data):
        path = os.path.join(self.folder.name, "model.glb")
        with open(path, "wb") as file:
            file.write(data)
        return path

    def test_reads_the_node_tree_by_path(self):
        report = read_glb(self.write(_glb(DOCUMENT, b"1234")))
        self.assertEqual(report.roots, ["Island", "Pads"])
        self.assertEqual(report.paths, ["Island", "Island/Rock", "Island/Copy", "Pads"])

    def test_counts_the_triangles_of_every_mesh_instance(self):
        report = read_glb(self.write(_glb(DOCUMENT, b"1234")))
        self.assertEqual(report.triangles, 2 * (4 + 2))
        self.assertEqual(report.triangles_under("Island/Rock"), 6)
        self.assertEqual(report.draw_calls, 4)

    def test_lists_the_materials(self):
        report = read_glb(self.write(_glb(DOCUMENT, b"1234")))
        self.assertEqual(report.materials, ["rock", "glow"])

    def test_gives_the_translation_of_a_node(self):
        report = read_glb(self.write(_glb(DOCUMENT, b"1234")))
        self.assertEqual(report.translation("Island/Copy"), (1, 2, 3))
        self.assertEqual(report.translation("Pads"), (0, 0, 0))

    def test_gives_the_bounds_of_the_positions(self):
        report = read_glb(self.write(_glb(DOCUMENT, b"1234")))
        self.assertEqual(report.bounds, ((-1, -2, -3), (1, 2, 3)))
        self.assertEqual(report.bounds_of("Island/Copy"), ((-1, -2, -3), (1, 2, 3)))

    def test_hashes_the_geometry_only(self):
        one = read_glb(self.write(_glb(DOCUMENT, b"1234")))
        renamed = dict(DOCUMENT, asset={"version": "2.0", "generator": "other"})
        two = read_glb(self.write(_glb(renamed, b"1234")))
        three = read_glb(self.write(_glb(DOCUMENT, b"1235")))
        self.assertEqual(one.geometry_hash, two.geometry_hash)
        self.assertNotEqual(one.geometry_hash, three.geometry_hash)

    def test_reads_the_size_of_embedded_and_side_images(self):
        png = _png_header(256, 128)
        with open(os.path.join(self.folder.name, "atlas.png"), "wb") as file:
            file.write(_png_header(512, 512))
        document = dict(DOCUMENT, bufferViews=[{"buffer": 0, "byteOffset": 4,
                                                "byteLength": len(png)}],
                        images=[{"bufferView": 0, "mimeType": "image/png"},
                                {"uri": "atlas.png"}])
        report = read_glb(self.write(_glb(document, b"1234" + png)))
        self.assertEqual(report.images, [(256, 128), (512, 512)])

    def test_refuses_a_file_that_is_no_glb(self):
        with self.assertRaises(ValueError):
            read_glb(self.write(b"not a glb at all"))


if __name__ == "__main__":
    unittest.main()
