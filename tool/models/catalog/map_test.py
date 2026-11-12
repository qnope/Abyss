"""Tests of the contents of the map, in the glTF space the game reads (Y up):
each stands on the floor under the centre of its cell (the volcano on the
middle of its 2 x 2), within its footprint, the tintable ones carry a Tint
that is a single lamp mesh, and the heights keep the order the map's legend
relies on (the volcano tallest, the hard lair over the medium one over the
easy one, the treasure smallest)."""

import unittest

from catalog import MODELS, mapkit
from catalog.buildings_test import SPILL, _boxes
from catalog.textures import map as tiles
from model_builds import built

KINDS = ["treasure", "ruins", "wreck", "lair_easy", "lair_medium", "lair_hard", "faille", "cheminee",
         "passage", "kernel", "home", "faction_base", "resource_algae", "resource_coral", "resource_ore"]
NAMES = [f"map_{kind}" for kind in KINDS]
TINTED = ["map_faille", "map_cheminee", "map_passage", "map_kernel", "map_faction_base"]
TALLEST = 2.0  # MapGrid.TALLEST, the top of the box the map's picking uses


def _top(name):
    return max(high[1] for _, high in _boxes(built(name)[1]))


def _lamp_primitives(report, path):
    """The materials of the primitives of the mesh node [path]."""
    document = report.document
    node = next(n for n in document["nodes"] if n.get("name") == path)
    return [document["materials"][p["material"]]["name"] for p in document["meshes"][node["mesh"]]["primitives"]]


class MapContentsTest(unittest.TestCase):
    def test_the_catalog_holds_one_model_per_kind_in_the_map_family(self):
        self.assertEqual(sorted(n for n in MODELS if n.startswith("map_")), sorted(NAMES))
        for name in NAMES:
            with self.subTest(name):
                self.assertEqual(MODELS[name].FAMILY, mapkit.FAMILY)

    def test_the_tintable_ones_alone_carry_a_tint_node(self):
        for name in NAMES:
            with self.subTest(name):
                self.assertIn(mapkit.BODY, built(name)[1].paths)
                self.assertEqual(mapkit.TINT in built(name)[1].paths, name in TINTED)
                self.assertEqual(mapkit.TINT in MODELS[name].NODES, name in TINTED)

    def test_the_tint_is_one_lamp_mesh_not_floating_above_the_floor_or_the_passage_rim(self):
        for name in TINTED:
            with self.subTest(name):
                report = built(name)[1]
                self.assertEqual(_lamp_primitives(report, mapkit.TINT), ["lamp"])
                self.assertGreater(report.triangles_under(mapkit.TINT), 50)
                self.assertLessEqual(report.bounds_of(mapkit.TINT)[0][1], 0.11)

    def test_every_content_stands_on_the_floor(self):
        for name in NAMES:
            with self.subTest(name):
                lowest = min(low[1] for low, _ in _boxes(built(name)[1]))
                self.assertAlmostEqual(lowest, 0.0, delta=0.15)

    def test_every_content_stays_within_its_cells(self):
        for name in NAMES:
            with self.subTest(name):
                half = 1.0 if name == "map_kernel" else 0.5
                boxes = list(_boxes(built(name)[1]))
                reach = max(max(abs(low[a]), abs(high[a])) for low, high in boxes for a in (0, 2))
                self.assertLessEqual(reach, half + SPILL)
                self.assertGreater(reach, half * 0.8)

    def test_the_heights_keep_the_order_of_the_legend(self):
        tops = {name: _top(name) for name in NAMES}
        self.assertEqual(max(tops, key=tops.get), "map_kernel")
        self.assertLessEqual(tops["map_kernel"], TALLEST + 0.05)
        self.assertGreater(tops["map_kernel"], 1.8)
        self.assertGreater(tops["map_lair_hard"], tops["map_lair_medium"] + 0.2)
        self.assertGreater(tops["map_lair_medium"], tops["map_lair_easy"] + 0.2)
        self.assertEqual(min(tops, key=tops.get), "map_treasure")

    def test_every_atlas_is_a_512_px_one_cut_in_64_px_cells(self):
        for name in NAMES:
            with self.subTest(name):
                self.assertEqual(MODELS[name].ATLAS.size, tiles.SIZE)
                self.assertEqual(MODELS[name].ATLAS.grid, tiles.GRID)


class TilePackingTest(unittest.TestCase):
    def test_pack_puts_the_biggest_first_without_overlap(self):
        cells = tiles.pack({"a": (1, 1), "big": (4, 2), "b": (2, 2), "c": (1, 1)})
        self.assertEqual(cells["big"], (0, 0, 4, 2))
        taken = set()
        for column, row, width, height in cells.values():
            spot = {(column + i, row + j) for i in range(width) for j in range(height)}
            self.assertFalse(spot & taken)
            taken |= spot

    def test_pack_refuses_what_does_not_fit(self):
        with self.assertRaises(ValueError):
            tiles.pack({f"t{k}": (3, 3) for k in range(8)})

    def test_an_atlas_always_holds_the_plain_tile_and_refuses_an_unknown_one(self):
        self.assertIn("plain", tiles.atlas("lava").tiles)
        with self.assertRaises(KeyError):
            tiles.atlas("nothing")


if __name__ == "__main__":
    unittest.main()
