"""The floor of the map's level 1, the sunlit reef shallows ("Surface"): the
tiles of one cell the game lays on the grid, Lit1..Lit3 (a cell seen) and
Fog1..Fog2 (a cell not seen yet, lower and dark). Each node's mesh is a tile
centred on its origin, its top at y = 0 (the fog's at -0.2), its border held
at one level so that any two tiles meet; the nodes stand apart for review
only. Read seabed/level.py."""

from catalog.seabed import level
from catalog.seabed.reef import LEVEL
from catalog.textures import seabed
from workshop.budget import Budget

NAME = "map_terrain_1"
SEED = LEVEL.seed
FAMILY = "map"
MATERIALS = level.MATERIALS
OCCLUSION = level.OCCLUSION
ATLAS = seabed.atlas_of(LEVEL.look)
BUDGET = Budget(triangles=3_000, materials=2, texture_px=512)
NODES = level.nodes(LEVEL)


def build(model):
    level.lay(model, LEVEL)
