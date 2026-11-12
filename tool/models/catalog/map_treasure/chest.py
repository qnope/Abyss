"""The parts of the treasure: its bank of silt, the chest, its heap and what
spilled out of it."""

import math

from catalog.decor import corals
from catalog.parts import bank as bank_
from catalog.parts import dress, extrude, loot, place
from workshop import noise, shapes
from workshop.builder import painted
from workshop.colors import linear, scale

WOOD = linear("#b0703c")
LINING = linear("#9a2d40")
TOP = 0.05  # the bank's top, where the chest stands
BODY = (0.6, 0.38, 0.23)
RISE = 0.14  # the lid's vault
OPEN = math.radians(-100)  # how far the lid is thrown back
LID_BASE = TOP + BODY[2]
BAND = BODY[0] * 0.34  # where the gold bands clasp the chest


def bank(into, atlas, rng):
    """A low bank of silt under the chest and the loot, a coral on it."""
    bank_.bank(into, atlas, 0.52, TOP)
    place(into, dress(corals.staghorn(rng, 0.42), atlas), (0.34, 0.3, TOP - 0.02))


def chest(into, atlas):
    """The chest of planks on the bank, banded in gold, brimming, its lid open."""
    body = shapes.box(BODY, bevel=0.015, bottom=False).transform((0, 0, TOP))
    into.add(body, "hull", _planks(1), atlas.tiled("weathered", 0.45)(body))
    for x in (-BAND, BAND):
        band = shapes.box((0.05, BODY[1] + 0.012, BODY[2] + 0.01), bevel=0.006, bottom=False)
        band.transform((x, 0, TOP))
        into.add(band, "hull", loot.GOLD, atlas.solid("plain")(band))
    heap = loot.heap(atlas, BODY[0] / 2 - 0.035, BODY[1] / 2 - 0.035, 0.085, seed=5)
    place(into, heap, (0, 0, LID_BASE - 0.01))
    for tile, x, size in (("pink", -0.1, 0.07), ("cyan", 0.08, 0.06), ("green", 0.0, 0.05)):
        place(into, loot.gem(atlas, size, tile, 0.2), (x, -0.02 + 0.3 * x, LID_BASE + 0.05))
    _lid(into, atlas)


def _planks(seed):
    def paint(p, normal):
        shade = 1.0 if normal.z > 0.7 else 0.8
        return scale(WOOD, shade * (0.9 + 0.2 * noise.fbm(p * 6, seed, octaves=2)))
    return paint


def _lid(into, atlas):
    """The vaulted lid, hinged at the back, thrown open past the vertical: its
    lining faces the camera."""
    hinge = BODY[1] / 2
    lid = extrude.vault(BODY[1], RISE, BODY[0], steps=8, bevel=0.01)
    lining = painted(lid, lambda p, n: LINING if n.z < -0.5 else scale(WOOD, 1.1 if n.z > 0.5 else 0.9))
    mapped = atlas.tiled("weathered", 0.45)(lid)
    extrude.tilted(lid, (hinge, 0), OPEN).transform((0, 0, LID_BASE))
    into.add(lid, "hull", lining, mapped)
    for x in (-BAND, BAND):
        band = extrude.vault(BODY[1] + 0.012, RISE + 0.008, 0.055, steps=8, bevel=0.005)
        extrude.tilted(band.transform((x, 0, 0)), (hinge, 0), OPEN).transform((0, 0, LID_BASE))
        into.add(band, "hull", loot.GOLD, atlas.solid("plain")(band))


def spill(into, atlas, rng):
    """Coins and stones spilled over the bank, mostly toward the front."""
    for parts, x, y in loot.strewn(atlas, rng, 9, 0.42):
        if abs(x) > 0.3 or abs(y + 0.05) > 0.21:
            place(into, parts, (x, y - 0.05, TOP - 0.005))
    for tile, x, y, size in (("pink", -0.3, -0.24, 0.07), ("cyan", 0.28, -0.26, 0.06),
                             ("green", 0.05, -0.34, 0.055)):
        place(into, loot.gem(atlas, size, tile, 0.2), (x, y, TOP - 0.01))
