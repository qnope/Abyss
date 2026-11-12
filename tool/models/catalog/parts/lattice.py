"""Lattice work: a tapering four-legged tower of tubes, rings and cross
braces, and a spoked sheave to hang on top of one."""

from mathutils import Vector

from catalog import colors
from catalog.paints import machined
from workshop import shapes, sweep


def tower(atlas, base, top, height, levels=3, radius=0.014, colour=colors.HULL_DARK, seed=0):
    """A tower on z = 0: legs from the corners of a square of half-side
    [base] to one of [top], [levels] storeys, each storey ringed and braced
    with an X on every face."""
    paint = machined(colour, seed, soot=0.0)
    blank = atlas.solid("plain")

    def half(k):
        return base + (top - base) * k / levels

    parts = []

    def bar(a, b, r):
        tube = sweep.tube([Vector(a), Vector(b)], [r, r], sides=4, cap=False)
        tube.sharp_angle = 0.5
        parts.append((tube, "hull", paint, blank(tube)))

    for sx, sy in ((1, 1), (-1, 1), (-1, -1), (1, -1)):
        bar((sx * base, sy * base, 0), (sx * top, sy * top, height), radius * 1.6)
    for k in range(1, levels + 1):
        h0, h1, z0, z1 = half(k - 1), half(k), height * (k - 1) / levels, height * k / levels
        for (ax, ay), (bx, by) in (((1, 1), (-1, 1)), ((-1, 1), (-1, -1)), ((-1, -1), (1, -1)),
                                   ((1, -1), (1, 1))):
            bar((ax * h1, ay * h1, z1), (bx * h1, by * h1, z1), radius)
            bar((ax * h0, ay * h0, z0), (bx * h1, by * h1, z1), radius * 0.7)
            bar((bx * h0, by * h0, z0), (ax * h1, ay * h1, z1), radius * 0.7)
    return parts


def cap(atlas, side, thick=0.04, colour=colors.HULL, seed=0):
    """A square landing at the head of a tower, centred, standing on z = 0."""
    plate = shapes.box((side, side, thick), bevel=0.008)
    return [(plate, "hull", machined(colour, seed, soot=0.0),
             atlas.fit("tread")(plate))]
