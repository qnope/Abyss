"""The floor of the map's level 2, the twilight mid-depths ("Depths"): the
tiles of one cell the game lays on the grid, Lit1..Lit3 (a cell seen) and
Fog1..Fog2 (a cell not seen yet, lower and dark), as for level 1 (see
map_terrain_1 and seabed/level.py): cold blue-grey silt, violet fans, ember
sponges."""

from catalog.seabed import level
from catalog.seabed.twilight import LEVEL
from catalog.textures import seabed
from workshop.budget import Budget

NAME = "map_terrain_2"
SEED = LEVEL.seed
FAMILY = "map"
MATERIALS = level.MATERIALS
OCCLUSION = level.OCCLUSION
ATLAS = seabed.atlas_of(LEVEL.look)
BUDGET = Budget(triangles=3_000, materials=2, texture_px=512)
NODES = level.nodes(LEVEL)


def build(model):
    level.lay(model, LEVEL)
