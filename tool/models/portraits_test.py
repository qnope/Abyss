"""The portraits committed in godot/assets/portraits/ are the ones the models
declare: one square PNG for each, none left over. Pixels are not compared (another
machine's renderer draws the last bits differently), only the declared list and
the size."""

import os
import re
import struct
import tempfile
import unittest
from unittest import mock

import portraits

RGBA = 6


def _header(path):
    """The width, height, bit depth and colour type of the PNG at [path]."""
    with open(path, "rb") as file:
        data = file.read(26)
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"{path} is not a PNG file")
    return struct.unpack(">IIBB", data[16:26])


class PortraitsTest(unittest.TestCase):
    def test_the_buildings_of_the_prototype_and_the_production_declare_one(self):
        declared = portraits.declared()
        for name in ("headquarters", "solar_panel", "coral_citadel", "algae_farm", "coral_mine", "ore_extractor"):
            self.assertIn(name, declared)

    def test_every_declared_portrait_is_committed_as_a_square_transparent_png(self):
        for name in portraits.declared():
            with self.subTest(name):
                self.assertTrue(os.path.exists(portraits.path(name)), "tool/models/portraits.sh")
                width, height, depth, kind = _header(portraits.path(name))
                self.assertEqual((width, height), (portraits.SIDE, portraits.SIDE))
                self.assertEqual((depth, kind), (8, RGBA))
                self.assertTrue(os.path.exists(portraits.path(name) + ".import"))

    def test_no_portrait_is_committed_for_a_model_that_declares_none(self):
        committed = sorted(f[:-4] for f in os.listdir(portraits.FOLDER) if f.endswith(".png"))
        self.assertEqual(committed, sorted(portraits.declared()))

    def test_the_side_is_the_one_godot_renders(self):
        script = os.path.join(portraits.ROOT, "godot", "tool", "models", "portrait.gd")
        with open(script, encoding="utf-8") as file:
            side = re.search(r"^const SIDE := (\d+)", file.read(), re.MULTILINE)
        self.assertEqual(int(side.group(1)), portraits.SIDE)

    def test_selects_every_declared_model_or_the_ones_named(self):
        self.assertEqual(portraits.select([]), portraits.declared())
        self.assertEqual(portraits.select(["solar_panel"]), ["solar_panel"])

    def test_refuses_a_model_that_declares_no_portrait(self):
        with self.assertRaises(ValueError):
            portraits.select(["probe_fish"])
        with self.assertRaises(ValueError):
            portraits.select(["no_such_model"])

    def test_refuses_a_model_that_is_not_built_yet(self):
        with tempfile.TemporaryDirectory() as empty:
            with mock.patch.object(portraits, "MODELS_FOLDER", empty):
                with self.assertRaises(ValueError):
                    portraits.select(["solar_panel"])


if __name__ == "__main__":
    unittest.main()
