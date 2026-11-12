"""The ore of a resource bonus: a heap of dark, ore-streaked boulders on a
black bank, a cluster of tall blue glowing crystals thrusting out of them
(the colour of the ore extractor) and nuggets of raw metal in the rubble. A
resource cache of the map: dark and angular with blue light, against the
green rosette of the algae and the pink bush of the coral.

Not tintable. Front toward -y."""

import math

from catalog import mapkit
from catalog.decor import rocks
from catalog.parts import bank, crystals, dress, place
from catalog.textures import map as tiles
from workshop import shapes
from workshop.colors import linear

NAME = "map_resource_ore"
SEED = 7203
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("blue", "white", "glass", "plain", "coral", "stone")
BUDGET = mapkit.budget(3_000)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY]
SOOT = linear("#2a2f3a")
STEEL = linear("#aab4c4")
BASE = 0.05
BOULDERS = ((-0.2, 0.12, 0.26), (0.2, 0.14, 0.24), (0.0, -0.22, 0.22), (-0.32, -0.12, 0.15),
            (0.33, -0.1, 0.17), (0.05, 0.32, 0.15), (-0.1, -0.35, 0.12))


def build(model):
    atlas, rng, into = model.atlas, model.rng, mapkit.body(model)
    bank.bank(into, atlas, 0.47, BASE, SOOT)
    for x, y, size in BOULDERS:
        place(into, dress(rocks.boulder(rng, size), atlas), (x, y, BASE - 0.03), (0, 0, rng.uniform(0, 6.28)))
    place(into, crystals.cluster(atlas, rng, 7, 0.6, "blue", spread=0.3), (0.0, 0.02, BASE + 0.02))
    for k in range(6):
        a = 2 * math.pi * k / 6 + 0.3
        nugget = shapes.octahedron(0.035 + 0.01 * (k % 2)).transform(
            (0.37 * math.cos(a), 0.33 * math.sin(a), BASE + 0.03), (0.4, 0.3 * k, 0), scale=(1, 0.8, 0.7))
        into.add(nugget, "hull", STEEL, atlas.solid("plain")(nugget))
