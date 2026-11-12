"""The rig: the collar with its blue-lit hole, the tripod on hydraulic jacks
carrying the drive head, and the drill string (the node Drill) running
down into the hole; the bedrock it stands in, veined with blue."""

import math

from mathutils import Vector

from catalog import colors
from catalog.decor import rocks
from catalog.paints import machined
from catalog.parts import Into, dress, light, place, plumbing, production
from workshop import shapes, sweep
from workshop.colors import linear

PZ = 0.09  # the deck's top, above the pad
AT = (-0.05, 0.12)  # the drill's axis
STEEL = linear("#7d9cc4")  # blue-painted steel
HEAD = 0.9  # the drive head's height above the deck


def rig(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    place(into, production.deck(atlas, strip="blue", seed=70))
    wall = sweep.lathe([(0.35, 0.0), (0.34, 0.09), (0.28, 0.105)], sides=14, smooth=False)
    top = sweep.lathe([(0.28, 0.106), (0.1, 0.106)], sides=14, smooth=False)
    glow = sweep.lathe([(0.17, 0.108), (0.1, 0.108)], sides=14, smooth=False)
    hole = shapes.cylinder(0.1, 0.01, sides=14, bottom=False).transform((0, 0, 0.1))
    place(into, [(wall, "hull", machined(colors.HULL_DARK, 71, soot=0.3), atlas.fit("plate")(wall)),
                 (top, "hull", colors.WHITE, atlas.fit("hazard")(top)),
                 (glow, *light(atlas, "blue")), (hole, "hull", colors.GROOVE, None)], (*AT, PZ))
    _tripod(into, atlas)
    _drill(model, group, atlas)
    for x, y, size in ((-0.55, 0.52, 0.5), (-0.68, 0.12, 0.38), (-0.3, 0.7, 0.34)):
        place(into, dress(rocks.boulder(rng, size), atlas), (x, y, PZ - 0.04), (0, 0, rng.uniform(0, 6)))
    for x, y in ((-0.62, -0.18), (-0.42, -0.02)):
        lode = rocks.boulder(rng, 0.3)
        for geometry, *_ in lode:
            place(into, [(geometry, "lamp", colors.LAMP, atlas.tiled("veins_blue", 0.4)(geometry))],
                  (x, y, PZ - 0.02))


def _tripod(into, atlas):
    x, y = AT
    head = (x, y, PZ + HEAD)
    for k in range(3):
        a = math.pi / 2 + k * 2 * math.pi / 3
        foot = Vector((x + 0.31 * math.cos(a), y + 0.31 * math.sin(a), PZ + 0.1))
        leg = sweep.tube([foot, foot.lerp(Vector(head), 0.5), Vector(head) + Vector((0, 0, -0.04))],
                         [0.034, 0.028, 0.024], sides=6, cap=False)
        into.add(leg, "hull", machined(STEEL, 72 + k, soot=0.1), atlas.tiled("weathered", 0.5)(leg))
        base = Vector((x + 0.56 * math.cos(a), y + 0.56 * math.sin(a), PZ))
        jack = sweep.tube([base + Vector((0, 0, 0.03)), foot.lerp(Vector(head), 0.42)], [0.022, 0.016],
                          sides=6, cap=False)
        into.add(jack, "hull", colors.LIMESTONE, atlas.solid("plain")(jack))
        block = shapes.box((0.08, 0.08, 0.06), bevel=0.01, bottom=False).transform(
            (base.x, base.y, PZ), (0, 0, a))
        into.add(block, "hull", machined(colors.HULL_DARK, 75 + k), atlas.fit("bolt")(block))
    motor = shapes.box((0.27, 0.27, 0.2), bevel=0.015, bottom=False)
    cap = shapes.cylinder(0.065, 0.14, sides=8, bevel=0.006, bottom=False).transform((0, 0, 0.2))
    place(into, [(motor, "hull", machined(STEEL, 78, soot=0.1), atlas.fit("plate")(motor)),
                 (cap, "hull", machined(colors.HULL_DARK, 79), atlas.fit("bolt")(cap)),
                 (shapes.octahedron(0.04).transform((0.15, 0, 0.1)), *light(atlas, "blue")),
                 (shapes.octahedron(0.04).transform((0, -0.15, 0.1)), *light(atlas, "blue"))],
          (x, y, PZ + HEAD - 0.03), (0, 0, 0.6))
    hose = [(x, y + 0.05, PZ + HEAD + 0.2), (x + 0.25, y + 0.1, PZ + HEAD + 0.16), (x + 0.4, y, PZ + 0.35)]
    place(into, plumbing.pipe(atlas, hose, 0.016, colors.PIPE, 0, 80, 6))


def _drill(model, group, atlas):
    piece = model.piece(f"{group}/Drill", (*AT, PZ + 0.4))
    rod = shapes.cylinder(0.047, HEAD - 0.1, sides=8, bottom=False).transform((0, 0, -0.05))
    parts = [(rod, "hull", machined(colors.LIMESTONE, 81, soot=0.0), atlas.tiled("weathered", 0.4)(rod))]
    for k in range(3):
        path = [Vector((0.06 * math.cos(k * 2.09 + z * 10), 0.06 * math.sin(k * 2.09 + z * 10), z))
                for z in (i * 0.07 for i in range(11))]
        flute = sweep.tube(path, [0.014] * len(path), sides=4, cap=False)
        parts.append((flute, "hull", colors.PIPE, atlas.solid("plain")(flute)))
    for z in (0.15, 0.5):
        ring = shapes.cylinder(0.07, 0.04, sides=8, bevel=0.005).transform((0, 0, z))
        parts.append((ring, "hull", colors.WHITE, atlas.fit("hazard")(ring)))
    place(piece, parts, (0, 0, -0.3))  # the origin well above the pad: it turns about its axis
