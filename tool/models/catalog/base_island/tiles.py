"""The plates of the deck, each fitting one cell or a part of one, its top
at z = 0: stone slabs whole, halved, quartered, chipped or cracked, and metal
plates riveted, ribbed, with a hatch or a lit vent."""

import math

from workshop import shapes
from workshop.geometry import Geometry

SIDE = 0.94
GAP = 0.06
DEPTH = 0.14


def slab(width, depth, bevel=0.022, chips=()):
    """A stone slab of [width] x [depth], centred, its top at z = 0; each
    corner index in [chips] (0..3, counter-clockwise) broken off."""
    w, d = width / 2, depth / 2
    corners = [(-w, -d), (w, -d), (w, d), (-w, d)]
    outline = []
    for index, corner in enumerate(corners):
        if index not in chips:
            outline.append(corner)
            continue
        cut = 0.14 + 0.06 * (index % 3)
        for other in (corners[index - 1], corners[(index + 1) % 4]):
            dx, dy = other[0] - corner[0], other[1] - corner[1]
            length = math.hypot(dx, dy)
            outline.append((corner[0] + dx / length * cut, corner[1] + dy / length * cut))
    return shapes.prism(outline, DEPTH, bevel, 1, bottom=False).transform((0, 0, -DEPTH))


def split(parts, rng):
    """A cell's slabs: one, two halves or four quarters, as (geometry, x, y)."""
    if parts == 1:
        return [(slab(SIDE, SIDE), 0.0, 0.0)]
    half = (SIDE - GAP) / 2
    if parts == 2:
        across = rng.random() < 0.5
        size = (SIDE, half) if across else (half, SIDE)
        offset = (half + GAP) / 2
        return [(slab(*size), 0.0 if across else s * offset, s * offset if across else 0.0)
                for s in (-1, 1)]
    offset = (half + GAP) / 2
    return [(slab(half, half), sx * offset, sy * offset) for sx in (-1, 1) for sy in (-1, 1)]


def cracked(rng):
    """A slab broken in two along a jagged line, as (geometry, x, y)."""
    h = SIDE / 2
    cuts = [(-h, rng.uniform(-0.2, 0.2))]
    for x in (-0.15, 0.12):
        cuts.append((x, cuts[-1][1] + rng.uniform(-0.12, 0.12)))
    cuts.append((h, rng.uniform(-0.2, 0.2)))
    low = [(-h, -h), (h, -h)] + [(x, y - 0.012) for x, y in reversed(cuts)]
    high = [(x, y + 0.012) for x, y in cuts] + [(h, h), (-h, h)]
    return [(shapes.prism(low, DEPTH, 0.02, bottom=False).transform((0, 0, -DEPTH - 0.01)), 0.0, 0.0),
            (shapes.prism(high, DEPTH, 0.02, bottom=False).transform((0, 0, -DEPTH)), 0.0, 0.0)]


def metal_plate():
    return shapes.box((SIDE, SIDE, DEPTH - 0.012), bevel=0.012, bottom=False).transform((0, 0, -DEPTH))


def rivets():
    h = SIDE / 2 - 0.07
    geometry = Geometry()
    for x in (-h, h):
        for y in (-h, h):
            geometry.extend(shapes.cylinder(0.025, 0.02, sides=5, bottom=False).transform((x, y, -0.014)))
    return geometry


def ribs():
    geometry = Geometry()
    for y in (-0.25, 0.0, 0.25):
        geometry.extend(shapes.box((0.72, 0.06, 0.03), bevel=0.01, bottom=False).transform((0, y, -0.014)))
    return geometry


def hatch():
    geometry = shapes.cylinder(0.3, 0.03, sides=16, bevel=0.012).transform((0, 0, -0.014))
    geometry.extend(shapes.cylinder(0.2, 0.025, sides=16, bevel=0.008).transform((0, 0, 0.01)))
    return geometry.extend(shapes.box((0.08, 0.3, 0.03), bevel=0.01).transform((0.32, 0, -0.012)))


def vent_frame():
    """The frame and slats of a vent, over a lit pit (vent_light)."""
    h, t = SIDE / 2, 0.09
    geometry = Geometry()
    for x, y, w, d in ((0, h - t / 2, SIDE, t), (0, -h + t / 2, SIDE, t),
                       (h - t / 2, 0, t, SIDE - 2 * t), (-h + t / 2, 0, t, SIDE - 2 * t)):
        geometry.extend(shapes.box((w, d, DEPTH), bevel=0.012, bottom=False).transform((x, y, -DEPTH)))
    for y in (-0.2, 0.0, 0.2):
        geometry.extend(shapes.box((SIDE - 2 * t, 0.06, 0.03), bevel=0.008)
                        .transform((0, y, -0.05), (math.radians(25), 0, 0)))
    return geometry


def vent_light():
    h = SIDE / 2 - 0.09
    return Geometry([(-h, -h, -0.1), (h, -h, -0.1), (h, h, -0.1), (-h, h, -0.1)], [(0, 1, 2, 3)])
