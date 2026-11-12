"""The coral rampart around the base's island: a ring of coral stone just
beyond the deck's edge, open where the avenues leave it, with a bastion at
each corner and a post at each side of every gate. Same origin as the
island: the deck's centre, its top at z = 0.

It grows with the coral citadel in 3 tiers, which add up: Tier1 is the low
wall (level 1), Tier2 sets a second course on it (level 2), Tier3 crowns
it with merlons, coral and lanterns (level 3). The game shows the tiers up
to the citadel's level and hides the rest: each tier is a node of its own,
joined per material, so no tier is ever scaled or rebuilt."""

from catalog import palette
from catalog.base_rampart import crest, ring
from catalog.base_rampart import masonry
from catalog.base_rampart.masonry import course
from catalog.base_rampart.towers import towers
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "base_rampart"
SEED = 1408
MATERIALS = [palette.REEF, palette.GLOW, palette.GLOW_PINK]
ATLAS = masonry.ATLAS  # the grain of the reef stone, 512 px
BUDGET = Budget(triangles=20_000, materials=4, texture_px=512)
OCCLUSION = Occlusion(rays=20, distance=0.6, floor=0.35,
                      strength={"reef": 0.6, "glow": 0.0, "glow_pink": 0.0})
TIERS = ["Tier1", "Tier2", "Tier3"]
FAMILY = "decor"
NODES = TIERS

# The courses of the wall: (bottom, height, depth) for tiers 1 and 2.
COURSES = ((-0.1, 0.38, ring.THICKNESS), (0.27, 0.27, ring.THICKNESS * 0.86))


def build(model):
    rng = model.rng
    first = course(model, "Tier1", *COURSES[0], rng)
    crest.polyps(model, "Tier1", first, rng, COURSES[0][2], COURSES[0][1])
    crest.encrust(model, "Tier1", first, rng, COURSES[0][2])
    towers(model, "Tier1", 0, rng)
    second = course(model, "Tier2", *COURSES[1], rng, shortest=0.36, longest=0.6)
    crest.encrust(model, "Tier2", second, rng, COURSES[1][2], chance=0.2)
    towers(model, "Tier2", 1, rng)
    crenels = crest.merlons(model, "Tier3", second, rng, 0.2, COURSES[1][2] * 0.8, _clear)
    for (x, y, z), _, turn in crenels:
        if rng.random() < 0.5:
            for geometry, material, paint in crest.sprig(rng, rng.uniform(0.26, 0.4)):
                geometry.transform((x, y, z - 0.02), (0, 0, turn))
                model.add("Tier2", geometry, material, paint)
    towers(model, "Tier3", 2, rng)


def _clear(x, y):
    """Off the towers: far enough from the corners and the gates' posts."""
    near = list(ring.CORNERS) + [point for point, _ in ring.gate_ends()]
    return all(max(abs(x - px), abs(y - py)) > 0.62 for px, py in near)
