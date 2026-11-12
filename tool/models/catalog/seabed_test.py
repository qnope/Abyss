"""The map's floor: the tiles of each level meet without a seam on a grid, in
any variant and any quarter turn, stay inside their cell and low, and the fog's
tiles lie under the lit ones."""

import random
import unittest
from unittest import mock

from mathutils import Vector

from catalog import MODELS
from catalog.seabed import level as levels
from catalog.seabed.ground import EDGE_DROP, FOOT, heightfield
from catalog.seabed.reef import LEVEL as REEF
from catalog.seabed.tile import Tile
from catalog.seabed.trench import LEVEL as TRENCH
from catalog.seabed.twilight import LEVEL as TWILIGHT
from model_builds import built
from workshop.scene import fresh_scene

LEVELS = (REEF, TWILIGHT, TRENCH)
STEPS = [k / 12 - 0.5 for k in range(13)]
UP = Vector((0, 0, 1))


def _tiles(level):
    """Every variant of [level], lit then hidden, laid by its recipe on a stand-in model."""
    fresh_scene()
    model = mock.MagicMock()
    model.atlas.rect.return_value = (0.0, 0.0, 1.0, 1.0)
    tiles = []
    for row, recipes in enumerate((level.lit, level.hidden)):
        for k, recipe in enumerate(recipes):
            tile = Tile(model, level, f"T{row}{k}", (0, 0, 0), level.seed + 7 * k + row,
                        0.0 if row == 0 else -levels.FOG_DROP, "lit1")
            recipe(tile)
            tiles.append(tile)
    return tiles


def _turn(x, y, quarters):
    for _ in range(quarters % 4):
        x, y = -y, x
    return x, y


def _edge(tile, side, quarters):
    """The ground's height and colour along the [side] (0 east, 1 north, 2 west, 3 south)
    of [tile] turned by [quarters] quarter turns, as seen from outside the cell."""
    paint = tile._paint(tile.level.sand, tile.level.patch)
    samples = []
    for t in STEPS:
        x, y = [(0.5, t), (-t, 0.5), (-0.5, -t), (t, -0.5)][side]
        sx, sy = _turn(x, y, -quarters)  # the point of the unturned tile
        samples.append((round(tile.height(sx, sy), 5),
                        tuple(round(c, 4) for c in paint(Vector((sx, sy, 0)), UP))))
    return samples


class SeabedTest(unittest.TestCase):
    def test_the_border_of_every_variant_is_at_one_height_and_one_colour(self):
        for level in LEVELS:
            tiles = _tiles(level)
            for tile in tiles:
                with self.subTest(f"{level.number}{tile.path}"):
                    edge = tile.top + EDGE_DROP
                    for side in range(4):
                        heights = {h for h, _ in _edge(tile, side, 0)}
                        self.assertEqual(heights, {round(edge, 5)})
                    corners = [verts for verts in heightfield(tile.height).verts
                               if abs(verts.x) == 0.5 or abs(verts.y) == 0.5]
                    self.assertEqual({round(v.z, 5) for v in corners}, {round(edge, 5)})
            for side in range(4):
                colours = {tuple(c for _, c in _edge(tile, side, 0)) for tile in tiles[:len(level.lit)]}
                self.assertEqual(len(colours), 1, f"the lit tiles of level {level.number}, side {side}")

    def test_a_five_by_five_board_of_any_variants_and_turns_meets_at_every_edge(self):
        dice = random.Random(3)
        for level in LEVELS:
            tiles = _tiles(level)[:len(level.lit)]
            board = [[(dice.choice(tiles), dice.randrange(4)) for _ in range(5)] for _ in range(5)]
            for j in range(5):
                for i in range(4):
                    (left, lq), (right, rq) = board[j][i], board[j][i + 1]
                    east = _edge(left, 0, lq)
                    west = _edge(right, 2, rq)
                    self.assertEqual(east, west[::-1])

    def test_every_tile_stays_inside_its_cell_and_low(self):
        for name, high in (("map_terrain_1", 0.45), ("map_terrain_2", 0.45), ("map_terrain_3", 0.45)):
            report = built(name)[1]
            for path in MODELS[name].NODES:
                with self.subTest(f"{name}/{path}"):
                    (x0, y0, z0), (x1, y1, z1) = report.bounds_of(path)
                    self.assertGreaterEqual(min(x0, z0), -0.5 - 1e-4)
                    self.assertLessEqual(max(x1, z1), 0.5 + 1e-4)
                    self.assertAlmostEqual(y0, FOOT, places=4)
                    self.assertLess(y1, high)

    def test_the_fog_lies_under_the_lit_tiles(self):
        for name in ("map_terrain_1", "map_terrain_2", "map_terrain_3"):
            report = built(name)[1]
            lit = [report.bounds_of(p)[1][1] for p in MODELS[name].NODES if p.startswith("Lit")]
            fog = [report.bounds_of(p)[1][1] for p in MODELS[name].NODES if p.startswith("Fog")]
            self.assertGreaterEqual(len(lit), 3)
            self.assertGreaterEqual(len(fog), 2)
            self.assertLess(max(fog), -0.1)
            self.assertGreater(min(lit), 0.05)

    def test_each_level_has_its_own_nodes_and_atlas(self):
        for level, name in zip(LEVELS, ("map_terrain_1", "map_terrain_2", "map_terrain_3")):
            script = MODELS[name]
            self.assertEqual(script.NODES, levels.nodes(level))
            self.assertEqual(script.FAMILY, "map")
            self.assertEqual(script.SEED, level.seed)
        self.assertEqual(len({level.seed for level in LEVELS}), 3)


if __name__ == "__main__":
    unittest.main()
