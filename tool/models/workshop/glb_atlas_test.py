"""Tests of the atlas' link into a glb: its textured materials take the PNG
next to it, and the geometry is left as it was."""

import json
import os
import struct
import tempfile
import unittest

from workshop.glb import read_glb
from workshop.glb_atlas import link_atlas
from workshop.glb_test import DOCUMENT, _glb, _png_header

BINARY = bytes(range(16))


def _document_of(path):
    with open(path, "rb") as file:
        data = file.read()
    length = struct.unpack_from("<I", data, 12)[0]
    return json.loads(data[20:20 + length]), data


class GlbAtlasTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.path = os.path.join(self.folder.name, "model.glb")
        document = json.loads(json.dumps(DOCUMENT))
        document["materials"] = [{"name": "rock", "pbrMetallicRoughness": {"roughnessFactor": 0.9}},
                                 {"name": "glow", "emissiveFactor": [1, 1, 1]}]
        with open(self.path, "wb") as file:
            file.write(_glb(document, BINARY))
        with open(os.path.join(self.folder.name, "model_atlas.png"), "wb") as file:
            file.write(_png_header(512, 512))

    def tearDown(self):
        self.folder.cleanup()

    def test_gives_the_textured_materials_the_atlas_as_base_colour(self):
        link_atlas(self.path, "model_atlas.png", ["rock", "glow"], ["glow"])
        document, _ = _document_of(self.path)
        self.assertEqual(document["images"], [{"uri": "model_atlas.png", "mimeType": "image/png"}])
        self.assertEqual(document["textures"], [{"sampler": 0, "source": 0}])
        rock, glow = document["materials"]
        self.assertEqual(rock["pbrMetallicRoughness"],
                         {"roughnessFactor": 0.9, "baseColorTexture": {"index": 0}})
        self.assertNotIn("emissiveTexture", rock)
        self.assertEqual(glow["emissiveTexture"], {"index": 0})
        self.assertEqual(glow["pbrMetallicRoughness"]["baseColorTexture"], {"index": 0})

    def test_samples_it_smoothly_with_mipmaps_and_clamped(self):
        link_atlas(self.path, "model_atlas.png", ["rock"], [])
        sampler = _document_of(self.path)[0]["samplers"][0]
        self.assertEqual(sampler, {"magFilter": 9729, "minFilter": 9987,
                                   "wrapS": 33071, "wrapT": 33071})

    def test_leaves_the_geometry_and_the_other_materials_alone(self):
        before = read_glb(self.path).geometry_hash
        link_atlas(self.path, "model_atlas.png", ["rock", "metal"], [])
        report = read_glb(self.path)
        self.assertEqual(report.geometry_hash, before)
        self.assertEqual(report.images, [(512, 512)])
        self.assertNotIn("baseColorTexture", _document_of(self.path)[0]["materials"][1])

    def test_keeps_the_chunks_aligned(self):
        link_atlas(self.path, "model_atlas.png", ["rock"], [])
        _, data = _document_of(self.path)
        length = struct.unpack_from("<I", data, 12)[0]
        self.assertEqual(length % 4, 0)
        self.assertEqual(struct.unpack_from("<I", data, 8)[0], len(data))
        self.assertEqual(data[-len(BINARY):], BINARY)


if __name__ == "__main__":
    unittest.main()
