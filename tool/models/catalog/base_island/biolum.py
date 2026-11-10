"""Bioluminescence on the plateau's sides and spire: glowing dots scattered
in the rock and veins running along the grooves between strata."""

import math

from mathutils import Vector

from catalog import colors
from workshop import shapes, sweep

GROUP = "Island"
# The rings of a body column that run in the grooves between strata.
GROOVES = (12, 15, 18, 21, 24, 27)


def biolum(model, columns, spire_rings):
    rng = model.rng
    dots = []
    for column in columns:
        for point in column[11:-2]:
            if rng.random() < 0.05:
                dots.append(point)
    for ring in spire_rings[1:-2]:
        for point in ring:
            if rng.random() < 0.06:
                dots.append(point)
    for point in dots:
        out = Vector((point.x, point.y, 0)).normalized() * 0.03
        pink = rng.random() < 0.18
        dot = shapes.octahedron(rng.uniform(0.022, 0.05)).transform(point + out)
        model.add(GROUP, dot, "glow_pink" if pink else "glow", colors.GLOW_PINK if pink else colors.GLOW_CYAN)
    for _ in range(22):
        _vein(model, rng, columns)
    for _ in range(7):
        _drip(model, rng, spire_rings)


def _vein(model, rng, columns):
    """A lit thread along a groove, over a few columns."""
    ring = rng.choice(GROOVES)
    start = rng.randrange(len(columns))
    length = rng.randrange(4, 12)
    points = []
    for k in range(length):
        p = columns[(start + k) % len(columns)][ring]
        points.append(p + Vector((p.x, p.y, 0)).normalized() * 0.025)
    model.add(GROUP, sweep.tube(points, [0.012] * len(points), sides=3, cap=False), "glow",
              colors.GLOW_CYAN)


def _drip(model, rng, rings):
    """A lit crack running down the spire."""
    column = rng.randrange(len(rings[0]))
    points = []
    for ring in rings[1:-3]:
        column = (column + rng.choice((-1, 0, 0, 1))) % len(ring)
        p = ring[column]
        points.append(p + Vector((p.x, p.y, 0)).normalized() * 0.03)
    radii = [0.018 * (1 - 0.5 * k / len(points)) for k in range(len(points))]
    model.add(GROUP, sweep.tube(points, radii, sides=3, cap=False), "glow", colors.GLOW_CYAN)
