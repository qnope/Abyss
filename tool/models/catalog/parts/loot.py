"""Sunken loot: coins, gems, a glowing heap of gold. Each maker gives parts
as (geometry, material, paint, uv) in its own frame, standing on z = 0."""

import math

from catalog.parts import light
from workshop import noise, shapes
from workshop.colors import linear, scale

GOLD = linear("#e8b730")
GOLD_DEEP = linear("#a8741c")


def coin(atlas, radius=0.04, tilt=0.0, seed=0):
    """A coin lying (or leaning by [tilt]) on z = 0."""
    disc = shapes.cylinder(radius, 0.012, sides=10, bevel=0.003, smooth=False, bottom=False)
    disc.transform((0, 0, 0.003), (tilt, 0, 0))
    return [(disc, "hull", scale(GOLD, 1 + 0.12 * math.sin(seed * 7)), atlas.solid("plain")(disc))]


def gem(atlas, size, tile, tilt=0.0):
    """A cut stone: a double pyramid of light, [size] high."""
    stone = shapes.octahedron(size * 0.5).transform((0, 0, size * 0.55), (tilt, 0, tilt),
                                                    scale=(0.85, 0.85, 1.25))
    return [(stone, *light(atlas, tile))]


def heap(atlas, rx, ry, height, seed=0, tile="bullion"):
    """A lumpy dome of gold that glows: coins by the thousand, one lamp."""
    dome = shapes.sphere(1.0, subdivisions=2)
    dome.displace(lambda p: p.normalized() * 0.16 * noise.fbm(p * 2.2, seed))
    shapes.flatten_below(dome, 0.0, 0.0)
    dome.transform((0, 0, 0), scale=(rx, ry, height))
    return [(dome, *light(atlas, tile))]


def strewn(atlas, rng, count, reach):
    """[count] coins strewn within [reach] of the origin, as (parts, x, y)."""
    spots = []
    for k in range(count):
        a, d = rng.uniform(0, 2 * math.pi), reach * math.sqrt(rng.uniform(0.25, 1.0))
        spots.append((coin(atlas, rng.uniform(0.032, 0.045), rng.uniform(-0.5, 0.5), k),
                      d * math.cos(a), d * math.sin(a)))
    return spots
