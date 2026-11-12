"""The big shapes that stand out beyond the map's rim, to be read as
silhouettes in the haze: a kelp forest, a whale's skeleton, basalt spires and
a smoker's chimney. Each fills a piece of the model, standing on z = 0 at its
origin, a few cells across."""

import math

from mathutils import Vector

from catalog import colors, paints
from catalog.decor import algae, rocks
from workshop import shapes, sweep
from workshop.colors import scale, vary

BONE = colors.LIMESTONE


def _add(piece, parts, at, turn=0.0):
    for geometry, material, paint in parts:
        geometry.transform(at, (0, 0, turn))
        piece.add(geometry, material, paint)


def kelp_forest(piece, rng, count=9, tallest=3.2):
    """Strands of kelp rising from one rocky foot, the tallest in the middle."""
    _add(piece, rocks.boulder(rng, 0.7), (0, 0, -0.1))
    for k in range(count):
        a, r = rng.uniform(0, 6.28), rng.uniform(0.1, 0.7)
        height = tallest * rng.uniform(0.55, 1.0) * (1.1 - r * 0.5)
        _add(piece, algae.kelp(rng, height), (math.cos(a) * r, math.sin(a) * r, 0.0), rng.uniform(0, 6.28))


def whale(piece, rng, length=6.0):
    """A whale's skeleton lying half in the silt: a spine, ribs arching over
    it and a long skull, bone-pale."""
    pale = scale(BONE, 0.9)
    bone = paints.organic(scale(pale, 0.6), pale, 3, variation=0.12, height=1.2)
    for k in range(15):
        t = k / 14
        x = -length / 2 + length * t * 0.8
        radius = 0.13 * (1 - 0.55 * abs(t - 0.35))
        verte = shapes.cylinder(radius, 0.2, sides=7, smooth=False)
        verte.transform((x, 0, 0.2), (0, math.pi / 2, 0))
        piece.add(verte, "rock", bone)
        if 2 <= k <= 9:
            span = 0.9 * math.sin(math.pi * (k - 1.5) / 9) + 0.25
            for side in (-1, 1):
                path = [Vector((x, side * span * math.sin(a), 0.25 + span * 0.9 * math.cos(a) * 0.8))
                        for a in (0.0, 0.45, 0.9, 1.35, 1.7)]
                piece.add(sweep.tube(path, [0.05, 0.045, 0.04, 0.03, 0.015], sides=5), "rock", bone)
    skull = shapes.sphere(0.6, subdivisions=2)
    skull.transform((-length / 2 - 0.7, 0, 0.35), scale=(1.8, 0.8, 0.55))
    piece.add(skull, "rock", bone)
    for side in (-1, 1):
        jaw = sweep.tube([Vector((-length / 2 - 1.8, side * 0.3, 0.12)),
                          Vector((-length / 2 - 0.8, side * 0.45, 0.08)),
                          Vector((-length / 2 - 0.1, side * 0.35, 0.18))], [0.05, 0.07, 0.05], sides=5)
        piece.add(jaw, "rock", bone)


def spires(piece, rng, count=7, tallest=4.2, glow=colors.GLOW_CYAN):
    """A group of basalt columns of different heights, leaning, cracked by
    seams that glow."""
    base = colors.BASALT_DEEP
    for k in range(count):
        a, r = rng.uniform(0, 6.28), rng.uniform(0.0, 0.9) if k else 0.0
        height = tallest * (1.0 if k == 0 else rng.uniform(0.3, 0.8))
        radius = rng.uniform(0.22, 0.38)
        column = shapes.prism(shapes.polygon(6, radius, rng.uniform(0, 1)), height, top=0.55,
                              bottom=False)
        lean = (rng.uniform(-0.1, 0.1), rng.uniform(-0.1, 0.1), rng.uniform(0, 6.28))
        column.transform((math.cos(a) * r, math.sin(a) * r, -0.3), lean)
        piece.add(column, "rock", paints.worked(vary(base, rng, 0.2), rng.randrange(99), mottle=0.25))
        seam = shapes.octahedron(0.05).transform((math.cos(a) * r, math.sin(a) * r, height * 0.6),
                                                 scale=(1, 1, 3.5))
        piece.add(seam, "glow", glow)


def chimney(piece, rng, height=2.6, glow=colors.GLOW_CYAN):
    """A smoker's chimney: a tapering stack ringed with mineral crust, a
    glowing mouth."""
    stack = shapes.cylinder(0.5, height, sides=9, top_radius=0.22, smooth=False, bottom=False)
    stack.transform((0, 0, -0.3))
    piece.add(stack, "rock", paints.worked(colors.BASALT, 5, mottle=0.3, grime=(colors.RUST, 0.7)))
    for z, radius in ((0.5, 0.5), (1.2, 0.38), (1.9, 0.3)):
        ring = shapes.cylinder(radius, 0.12, sides=9, top_radius=radius * 0.8, smooth=False)
        ring.transform((0, 0, z))
        piece.add(ring, "rock", paints.worked(colors.RUST, 6, mottle=0.3))
    mouth = shapes.cylinder(0.17, 0.08, sides=9)
    mouth.transform((0, 0, height - 0.32))
    piece.add(mouth, "glow", glow)
