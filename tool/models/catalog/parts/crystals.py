"""Crystals growing out of the ground: hexagonal glass shafts, their points
glowing, in a colour of the atlas (pink coral, blue ore)."""

import math

from catalog.parts import light
from workshop import shapes
from workshop.colors import linear, mix, scale
from workshop.geometry import Geometry

SHAFT = {"pink": linear("#ff5aa0"), "blue": linear("#2a6cff")}


def crystal(atlas, rng, length, radius, tile, tilt=0.35):
    """One crystal standing on z = 0, leaning at random: a glass shaft, a
    glowing point."""
    shaft = shapes.cylinder(radius, length * 0.68, sides=6, top_radius=radius * 0.9, smooth=False,
                            bottom=False)
    point = Geometry([(radius * 0.9 * math.cos(k * math.pi / 3), radius * 0.9 * math.sin(k * math.pi / 3),
                       length * 0.68) for k in range(6)] + [(0, 0, length)],
                     [(k, (k + 1) % 6, 6) for k in range(6)], smooth=False)
    lean = (rng.uniform(-tilt, tilt), rng.uniform(-tilt, tilt), rng.uniform(0, 3.14))
    base = SHAFT[tile]
    parts = []
    for geometry, material, paint, uv in (
            (shaft, "glass", mix(scale(base, 0.7), base, 0.5), atlas.fit("glass")(shaft)),
            (point, *light(atlas, tile))):
        geometry.transform((0, 0, -0.01), lean)
        parts.append((geometry, material, paint, uv))
    return parts


def cluster(atlas, rng, count, size, tile, spread=0.16):
    """[count] crystals of very different lengths packed around a point,
    the tallest at the heart: at most [size] high."""
    parts = []
    for k in range(count):
        a = rng.uniform(0, 2 * math.pi)
        d = 0.0 if k == 0 else rng.uniform(0.3, 1.0) * spread * size
        length = size * (1.0 if k == 0 else rng.uniform(0.35, 0.75))
        one = crystal(atlas, rng, length, length * rng.uniform(0.11, 0.16), tile)
        for geometry, *_ in one:
            geometry.transform((d * math.cos(a), d * math.sin(a), 0))
        parts += one
    return parts
