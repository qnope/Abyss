"""The building slots: one empty pad per building, each a node of its own
under Pads, its origin at the centre of its top, where the building stands.
A dark octagonal plinth with a lit groove and corner lights, under a top of
four concrete plates (a round one for the headquarters): two materials, so
two draw calls a pad."""

import math

from mathutils import Vector

from catalog import colors, paints
from catalog.base_island.layout import PAD_TOP, SLOTS, plan
from workshop import shapes
from workshop.colors import vary
from workshop.geometry import Geometry

BASE_TOP = -0.035


def pads(model):
    for index, slot in enumerate(SLOTS):
        x, y = plan(slot.u, slot.v)
        piece = model.piece(f"Pads/{slot.node}", (x, y, PAD_TOP))
        _pad(piece, slot.footprint, slot.building == "headquarters", model.rng, index)


def _pad(piece, footprint, round_top, rng, seed):
    side = footprint - 0.12
    chamfer = 0.3 * footprint / 2
    base = shapes.prism(shapes.chamfered_square(side, chamfer), BASE_TOP + PAD_TOP + 0.02,
                        bevel=0.025, segments=2, bottom=False)
    piece.add(base.transform((0, 0, -PAD_TOP - 0.02)), "stone",
              paints.worked(vary(colors.PAD_BASE, rng, 0.05), seed, edge=1.6))
    inner = shapes.chamfered_square(side - 0.16, chamfer - 0.05)
    piece.add(_ring(inner, 0.035, BASE_TOP + 0.002), "glow", colors.GLOW_CYAN)
    top = paints.worked(vary(colors.PAD, rng, 0.04), seed + 50, mottle=0.1, edge=1.5)
    plate = side - 0.3
    if round_top:
        disc = shapes.cylinder(plate / 2, 0.06, sides=28, bevel=0.015, bottom=False)
        piece.add(disc.transform((0, 0, -0.06)), "stone", top)
        piece.add(_ring(shapes.polygon(32, plate * 0.3), 0.03, 0.002), "glow", colors.GLOW_CYAN)
    else:
        for quarter in _quarters(plate, chamfer - 0.1, 0.035):
            piece.add(shapes.prism(quarter, 0.06, bevel=0.012, bottom=False).transform((0, 0, -0.06)),
                      "stone", top)
    h = side / 2 - chamfer / 2 - 0.03
    for sx, sy in ((1, 1), (-1, 1), (-1, -1), (1, -1)):
        light = shapes.cylinder(0.045, 0.035, sides=6, bottom=False)
        piece.add(light.transform((sx * h, sy * h, BASE_TOP)), "glow", colors.GLOW_CYAN)


def _quarters(side, chamfer, gap):
    """The four plates of a chamfered square of [side], [gap] apart."""
    h, c, g = side / 2, chamfer, gap / 2
    quarter = [(g, g), (h, g), (h, h - c), (h - c, h), (g, h)]
    result = []
    for sx, sy in ((1, 1), (-1, 1), (-1, -1), (1, -1)):
        points = [(sx * x, sy * y) for x, y in quarter]
        result.append(points if sx * sy > 0 else list(reversed(points)))
    return result


def _ring(outline, width, z):
    """A flat band [width] wide inside the polygon [outline], at height z."""
    geometry = Geometry()
    n = len(outline)
    for x, y in outline:
        length = math.hypot(x, y)
        geometry.verts.append((x, y, z))
        geometry.verts.append((x * (1 - width / length), y * (1 - width / length), z))
    for i in range(n):
        j = (i + 1) % n
        geometry.faces.append((2 * i, 2 * j, 2 * j + 1, 2 * i + 1))
    geometry.verts = [Vector(v) for v in geometry.verts]
    geometry.smooth = [False] * n
    return geometry
