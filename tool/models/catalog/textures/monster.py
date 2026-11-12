"""The monsters' atlas, 512 px on a 16 x 16 grid (32 px cells): four skins
the vertex colours tint (a slimy skin, scales, chitin plates, a scarred hide),
and the lights of the six hostile colours (acid, sulfur, ember, blood, lava, pale)
as plain tiles and as eyes with a slit pupil. Every monster has an atlas of
its own, painted from the same tiles with its own seed."""

import numpy

from catalog.textures import lights, monster_skins
from workshop.atlas import Atlas, Tile
from workshop.colors import linear

ACID = numpy.array(linear("#c8ff3c")) * 0.85
SULFUR = numpy.array(linear("#ffe033")) * 0.85
EMBER = numpy.array(linear("#ff6a1f")) * 0.85
BLOOD = numpy.array(linear("#ff2a2a")) * 0.85
LAVA = numpy.array(linear("#ff9a2a")) * 0.9
PALE = numpy.array(linear("#e8ffc8")) * 0.85

# Where each light is: a plain tile and an eye.
LIGHTS = {
    "acid": (ACID, (14, 12), (8, 14)),
    "sulfur": (SULFUR, (15, 12), (10, 14)),
    "ember": (EMBER, (14, 13), (12, 14)),
    "blood": (BLOOD, (15, 13), (14, 8)),
    "lava": (LAVA, (14, 14), (14, 10)),
    "pale": (PALE, (15, 14), (12, 8)),
}

TILES = {
    "plain": Tile((15, 15, 1, 1), lights.solid((1.0, 1.0, 1.0))),
    "skin": Tile((0, 0, 8, 8), monster_skins.skin, seamless=True),
    "scales": Tile((8, 0, 8, 8), monster_skins.scales, seamless=True),
    "plates": Tile((0, 8, 8, 8), monster_skins.plates, seamless=True),
    "hide": Tile((8, 8, 4, 4), monster_skins.hide, seamless=True),
}
for _name, (_colour, _cell, _eye) in LIGHTS.items():
    TILES[_name] = Tile((*_cell, 1, 1), lights.solid(_colour))
    TILES["eye_" + _name] = Tile((*_eye, 2, 2), monster_skins.eye(_colour))


def atlas(seed=0):
    """The monsters' atlas."""
    return Atlas(512, 16, TILES, seed)
