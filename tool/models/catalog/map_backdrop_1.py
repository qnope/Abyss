"""The backdrop of the map's level 1, the sunlit reef shallows ("Surface"):
the rim of the slab the grid stands on, a sandy shelf growing kelp, coral
and sponges before it falls away into the blue, and a kelp forest beyond.
Read backdrop/level.py for the pieces the game repeats and places."""

from catalog import backdrop
from catalog.backdrop import level
from catalog.backdrop.specs import REEF as SPEC
from workshop.budget import Budget

NAME = "map_backdrop_1"
SEED = SPEC.seed
FAMILY = "decor"
MATERIALS = backdrop.MATERIALS
OCCLUSION = backdrop.OCCLUSION
BUDGET = Budget(triangles=30_000, materials=4)
NODES = ["Edge1", "Edge2", "Corner"] + [name for name, _, _ in SPEC.far]


def build(model):
    level.lay(model, SPEC)
