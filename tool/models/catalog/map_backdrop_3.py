"""The backdrop of the map's level 3, the abyssal trench ("Core"): the rim of
the slab in black basalt, rubble on its shelf, then a trench wall falling into
the dark, basalt spires with glowing seams and a smoker's chimney beyond.
Read backdrop/level.py for the pieces the game repeats and places."""

from catalog import backdrop
from catalog.backdrop import level
from catalog.backdrop.specs import TRENCH as SPEC
from workshop.budget import Budget

NAME = "map_backdrop_3"
SEED = SPEC.seed
FAMILY = "decor"
MATERIALS = backdrop.MATERIALS
OCCLUSION = backdrop.OCCLUSION
BUDGET = Budget(triangles=30_000, materials=4)
NODES = ["Edge1", "Edge2", "Corner"] + [name for name, _, _ in SPEC.far]


def build(model):
    level.lay(model, SPEC)
