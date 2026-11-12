"""The backdrop of the map's level 2, the twilight mid-depths ("Depths"): the
rim of the slab in blue-grey rock, fans and sponges on its shelf, a whale's
skeleton and a kelp forest beyond, in the gloom. Read backdrop/level.py for
the pieces the game repeats and places."""

from catalog import backdrop
from catalog.backdrop import level
from catalog.backdrop.specs import TWILIGHT as SPEC
from workshop.budget import Budget

NAME = "map_backdrop_2"
SEED = SPEC.seed
FAMILY = "decor"
MATERIALS = backdrop.MATERIALS
OCCLUSION = backdrop.OCCLUSION
BUDGET = Budget(triangles=30_000, materials=4)
NODES = ["Edge1", "Edge2", "Corner"] + [name for name, _, _ in SPEC.far]


def build(model):
    level.lay(model, SPEC)
