"""The algae of a resource bonus: a rosette of broad kelp blades arching out
from a dark bank, green going to yellow at the tips, three tall fronds in
the middle ending in glowing green spore bulbs. A resource cache of the map:
seen from above it is a green star (and the green lights tell it from the
pink coral and the blue ore).

Not tintable. Front toward -y."""

import math

from catalog import colors, mapkit
from catalog.parts import bank, fronds, place
from catalog.textures import map as tiles
from workshop.colors import linear

NAME = "map_resource_algae"
SEED = 7201
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("green", "teal", "stone")
BUDGET = mapkit.budget(2_500)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY]
MUD = linear("#4f6b4a")
LEAF = linear("#1f9a4f")
TIP = linear("#8cc83a")
# (x, y, height) of the tall fronds at the heart.
FRONDS = ((0.0, 0.06, 0.55), (-0.13, -0.05, 0.42), (0.14, -0.04, 0.46))
BASE = 0.05


def build(model):
    atlas, rng, into = model.atlas, model.rng, mapkit.body(model)
    bank.bank(into, atlas, 0.47, BASE, MUD)
    for k in range(9):  # the rosette
        a = 2 * math.pi * k / 9 + 0.3
        length = rng.uniform(0.28, 0.38)
        place(into, fronds.blade(atlas, rng, (0.08 * math.cos(a), 0.08 * math.sin(a), BASE), a, length, 0.2,
                                 LEAF, TIP, rise=0.3), (0, 0, 0))
    for k, (x, y, height) in enumerate(FRONDS):
        place(into, fronds.frond(atlas, rng, height, LEAF, TIP, leaves=4), (x, y, BASE))
        place(into, fronds.bulb(atlas, 0.05 + 0.006 * k), (x, y, BASE + height + 0.04))
    for k in range(5):
        a = 2 * math.pi * k / 5 + 0.9
        place(into, fronds.tuft(atlas, rng, 0.16, colors.KELP), (0.38 * math.cos(a), 0.36 * math.sin(a), 0.03))
        place(into, fronds.bulb(atlas, 0.025, "teal"), (0.3 * math.cos(a + 0.5), 0.3 * math.sin(a + 0.5), 0.07))
