"""A faction's base: the fortified outpost of a rival, in the dark armour of
the barracks. A low octagonal apron, four battered corner towers joined by
crenellated walls, a gate toward the camera with a red glow behind it, a taller
keep at the heart with a harpoon launcher on its roof and a mast, and a banner,
pennants and a ring of lights at its foot in the faction's colour. It is the
most walled and the darkest thing of the map (0.85 high, 1.0 wide): the red
glow of its gate tells it from the lairs, the straight edges from the reef.

Tintable: Tint = the ring, the banner and the pennants (neutral white by
default, the faction's colour in the game). Front (the gate) toward -y."""

import math

from catalog import colors, mapkit
from catalog.mapkit import tints
from catalog.paints import machined
from catalog.parts import command_tech, place
from catalog.textures import map as tiles
from workshop import shapes
from workshop.colors import linear

NAME = "map_faction_base"
SEED = 8001
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("plate", "plate_tall", "tread", "strap", "bolt", "red", "white", "amber")
BUDGET = mapkit.budget(4_200)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY, mapkit.TINT]
IRON = linear("#6a7494")
IRON_DARK = linear("#3c4358")
CORNER, WALL, GATE = 0.34, 0.2, 0.15


def build(model):
    atlas, into = model.atlas, mapkit.body(model)
    apron = shapes.cylinder(0.5, 0.05, sides=8, top_radius=0.47, bevel=0.01, smooth=False, bottom=False)
    into.add(apron, "hull", machined(IRON_DARK, 1, soot=0.3), atlas.fit("plate")(apron))
    for sx in (-1, 1):
        for sy in (-1, 1):
            place(into, command_tech.tower(atlas, (0.2, 0.2), 0.36, IRON, seed=2 + sx + 2 * sy),
                  (sx * CORNER, sy * CORNER, 0.04))
    _walls(into, atlas)
    place(into, command_tech.tower(atlas, (0.34, 0.34), 0.5, IRON, seed=9), (0, 0.05, 0.04))
    place(into, command_tech.launcher(atlas, seed=3), (0, 0.0, 0.64), (0, 0, 0))
    place(into, tints.pole(atlas, 0.34), (0.1, 0.12, 0.64))
    for sx in (-1, 1):
        place(into, tints.pole(atlas, 0.22), (sx * CORNER, -CORNER, 0.4))
    _tint(model, atlas)


def _walls(into, atlas):
    """The walls between the towers; the front one is split by the gate."""
    side = 2 * CORNER - 0.16
    for k, (x, y, turn, length) in enumerate(((0, CORNER, 0, side), (-CORNER, 0, math.pi / 2, side),
                                              (CORNER, 0, math.pi / 2, side))):
        place(into, _wall(atlas, length, k), (x, y, 0.04), (0, 0, turn))
    half = (side - GATE) / 2
    for sx in (-1, 1):
        place(into, _wall(atlas, half, 5 + sx), (sx * (GATE + half) / 2, -CORNER, 0.04))
    glow = shapes.box((GATE, 0.02, WALL * 0.8), bottom=False).transform((0, -CORNER + 0.02, 0.04))
    into.add(glow, "lamp", colors.LAMP, atlas.solid("red")(glow))


def _wall(atlas, length, seed):
    wall = shapes.box((length, 0.07, WALL), bevel=0.01, bottom=False)
    wall.subdivide(0.3)
    parts = [(wall, "hull", machined(IRON, seed, soot=0.3), command_tech.sided(atlas, wall, "plate", "tread"))]
    return parts + command_tech.merlons(atlas, length, 0.07, WALL, IRON, step=0.13, size=0.06, seed=seed)


def _tint(model, atlas):
    piece = mapkit.tint(model)
    place(piece, tints.ring(atlas, 0.5, 0.06, 0.02, sides=8), (0, 0, 0.0))
    place(piece, tints.banner(atlas, 0.3, 0.2), (0.11, 0.12, 0.76))
    for sx in (-1, 1):
        place(piece, tints.banner(atlas, 0.12, 0.09), (sx * CORNER + 0.01, -CORNER, 0.5))
