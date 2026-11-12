"""Ways for ore to travel: a rail track, a cart and an inclined belt
conveyor, each loaded with chunks of its colour."""

import math

from mathutils import Vector

from catalog import colors
from catalog.paints import machined
from catalog.parts import light
from workshop import shapes
from workshop.colors import vary


def chunks(atlas, rng, count, spread, colour, glow=None, size=0.05):
    """A heap of [count] rough chunks of [colour] within [spread] (x, y),
    standing on z = 0, a few glowing in the colour of the tile [glow]."""
    parts = []
    for k in range(count):
        rock = shapes.sphere(size * rng.uniform(0.6, 1.2), 1, smooth=False)
        rock.transform((rng.uniform(-1, 1) * spread[0], rng.uniform(-1, 1) * spread[1],
                        size * rng.uniform(0.3, 0.9)), (rng.uniform(0, 3), rng.uniform(0, 3), 0),
                       (1, 1, 0.8))
        if glow and k % 3 == 0:
            parts.append((rock, *light(atlas, glow)))
        else:
            parts.append((rock, "reef", vary(colour, rng, 0.15), atlas.tiled("coral", 0.3)(rock)))
    return parts


def track(atlas, length, gauge=0.2, seed=0):
    """Two rails on ties along x, from x = 0 to [length], on z = 0."""
    parts = []
    for side in (-1, 1):
        rail = shapes.box((length, 0.022, 0.03), bevel=0.004, bottom=False)
        parts.append((rail, "hull", colors.LIMESTONE, atlas.solid("plain")(rail)))
        rail.transform((length / 2, side * gauge / 2, 0.02))
    for k in range(int(length / 0.08)):
        tie = shapes.box((0.04, gauge + 0.07, 0.02), bottom=False).transform((0.04 + k * 0.08, 0, 0))
        parts.append((tie, "hull", machined(colors.ROOT, seed + k, soot=0.0), atlas.fit("plate")(tie)))
    return parts


def cart(atlas, rng, colour, glow=None, seed=0):
    """A tipping cart along x on its four wheels, heaped with chunks."""
    trough = shapes.prism([(-0.14, -0.09), (0.14, -0.09), (0.14, 0.09), (-0.14, 0.09)], 0.1,
                          bevel=0.008, top=1.18, bottom=False).transform((0, 0, 0.05))
    parts = [(trough, "hull", machined(colors.HULL_DARK, seed, soot=0.2), atlas.fit("plate")(trough))]
    for x in (-0.08, 0.08):
        for y in (-0.1, 0.1):
            wheel = shapes.cylinder(0.035, 0.02, sides=8, bevel=0.004)
            wheel.transform((x, y - 0.01, 0.035), (math.pi / 2, 0, 0))
            parts.append((wheel, "hull", colors.METAL_DARK, atlas.fit("bolt")(wheel)))
    heap = chunks(atlas, rng, 7, (0.1, 0.06), colour, glow, 0.045)
    for geometry, *_ in heap:
        geometry.transform((0, 0, 0.12))
    return parts + heap


def conveyor(atlas, rng, start, end, colour, glow=None, width=0.14, seed=0):
    """An inclined belt from [start] to [end], on legs, loaded with chunks."""
    a, b = Vector(start), Vector(end)
    d = b - a
    pitch, yaw, length = math.atan2(d.z, math.hypot(d.x, d.y)), math.atan2(d.y, d.x), d.length
    pose = ((0, 0, 0), (0, -pitch, yaw))
    parts = []
    bed = shapes.box((length, width, 0.03), bevel=0.006)
    belt = shapes.box((length - 0.02, width - 0.04, 0.012), bevel=0.003).transform((length / 2, 0, 0.03))
    parts.append((belt, "hull", colors.GROOVE, atlas.fit("tread")(belt)))
    bed.transform((length / 2, 0, 0))
    parts.append((bed, "hull", machined(colors.HULL_DARK, seed, soot=0.2), atlas.fit("strap")(bed)))
    for side in (-1, 1):
        rail = shapes.box((length, 0.02, 0.05), bevel=0.004).transform((length / 2, side * width / 2, 0))
        parts.append((rail, "hull", machined(colors.HULL, seed + 1, soot=0.0), atlas.fit("strap")(rail)))
    load = chunks(atlas, rng, int(length / 0.11), (length / 2 - 0.05, width * 0.28), colour, glow, 0.035)
    for geometry, *_ in load:
        geometry.transform((length / 2, 0, 0.04))
    parts += load
    for geometry, *_ in parts:
        geometry.transform(a, pose[1])
    for t in (0.12, 0.5, 0.9):
        p = a + d * t
        for side in (-1, 1):
            across = Vector((-math.sin(yaw), math.cos(yaw), 0)) * side * width * 0.4
            leg = shapes.box((0.018, 0.018, max(p.z - 0.01, 0.02)), bottom=False)
            parts.append((leg, "hull", colors.HULL, atlas.solid("plain")(leg)))
            leg.transform((p.x + across.x, p.y + across.y, 0))
    return parts
