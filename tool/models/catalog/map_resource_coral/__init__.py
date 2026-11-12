"""The coral of a resource bonus: a bush of pink branching coral on a pale
bank, three staghorns and a rose brain coral round a cluster of glowing pink
crystals (the colour of the coral mine's shaft). A resource cache of the
map: wide, pink, branching, against the green rosette of the algae and the
dark blue-lit rocks of the ore.

Not tintable. Front toward -y."""

import math

from catalog import colors, mapkit
from catalog.decor import corals
from catalog.parts import bank, crystals, dress, place
from catalog.textures import map as tiles
from workshop.colors import linear

NAME = "map_resource_coral"
SEED = 7202
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("pink", "glass", "coral", "stone")
BUDGET = mapkit.budget(4_000)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY]
CHALK = linear("#d9c2bc")
BASE = 0.05
# (x, y, size, colour) of the staghorns round the crystals.
STAGS = ((-0.22, 0.1, 0.8, colors.CORAL_PINK), (0.2, 0.12, 0.7, colors.CORAL_DEEP),
         (0.0, -0.22, 0.6, colors.CORAL_ORANGE), (-0.3, -0.16, 0.45, colors.CORAL_PINK),
         (0.3, -0.12, 0.5, colors.CORAL_PINK))


def build(model):
    atlas, rng, into = model.atlas, model.rng, mapkit.body(model)
    bank.bank(into, atlas, 0.47, BASE, CHALK)
    place(into, crystals.cluster(atlas, rng, 7, 0.55, "pink", spread=0.22), (0.0, 0.02, BASE - 0.01))
    for x, y, size, colour in STAGS:
        place(into, dress(corals.staghorn(rng, size, colour), atlas), (x, y, BASE - 0.02),
              (0, 0, rng.uniform(0, 6.28)))
    for k in range(3):
        a = 2 * math.pi * k / 3 + 0.4
        place(into, dress(corals.brain(rng, 0.17), atlas), (0.38 * math.cos(a), 0.36 * math.sin(a), BASE - 0.02))
