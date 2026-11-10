"""Fittings on a hull's top: masts, dishes and beacons."""

import math

from catalog import colors
from catalog.paints import machined
from catalog.parts import light
from workshop import shapes, sweep


def dish(atlas, radius, depth, colour=colors.LIMESTONE, seed=0):
    """A sensor dish opening up z, its feed on three struts."""
    r, d = radius, depth
    bowl = sweep.lathe([(0.0, -0.02), (r * 0.45, 0.02), (r, d), (r * 1.04, d - 0.012),
                        (r * 0.5, 0.045), (0.0, 0.03)], sides=14)
    parts = [(bowl, "hull", machined(colour, seed, soot=0.0), atlas.fit("plate")(bowl))]
    for k in range(3):
        a = 2 * math.pi * k / 3
        strut = sweep.tube([(r * 0.8 * math.cos(a), r * 0.8 * math.sin(a), d * 0.8),
                            (0, 0, d + r * 0.55)], [0.006, 0.006], sides=3, cap=False)
        parts.append((strut, "hull", colors.METAL_DARK, None))
    feed = shapes.octahedron(r * 0.12).transform((0, 0, d + r * 0.58))
    parts.append((feed, *light(atlas, "cyan")))
    return parts


def beacon(atlas, radius, tile="cyan", colour=colors.METAL_DARK, seed=0):
    """A lamp in a cage of four bars under a cap, standing on z = 0."""
    r = radius
    base = shapes.cylinder(r * 1.25, r * 0.5, sides=8, top_radius=r * 1.05, bevel=0.006,
                           bottom=False)
    bulb = shapes.sphere(r, subdivisions=1).transform((0, 0, r * 1.4))
    cap = shapes.cylinder(r * 1.15, r * 0.35, sides=8, top_radius=r * 0.4).transform((0, 0, r * 2.5))
    parts = [(base, "hull", machined(colour, seed, soot=0.0), atlas.fit("bolt")(base)),
             (bulb, *light(atlas, tile)),
             (cap, "hull", machined(colour, seed + 1, soot=0.0), atlas.solid("plain")(cap))]
    for k in range(4):
        a = math.pi / 4 + k * math.pi / 2
        bar = shapes.box((0.012, 0.012, r * 2.1), bottom=False)
        bar.transform((r * 1.15 * math.cos(a), r * 1.15 * math.sin(a), r * 0.45))
        parts.append((bar, "hull", colour, atlas.solid("plain")(bar)))
    return parts


def mast(atlas, height, radius, colour=colors.METAL_DARK, seed=0):
    """A tapering mast up z, ringed with bands."""
    pole = shapes.cylinder(radius, height, sides=6, top_radius=radius * 0.6, smooth=True,
                           bottom=False)
    parts = [(pole, "hull", machined(colour, seed, soot=0.0), atlas.tiled("weathered", 0.5)(pole))]
    for k in range(1, 4):
        z = height * k / 4
        band = shapes.cylinder(radius * (1.25 - 0.1 * k), 0.03, sides=6).transform((0, 0, z))
        parts.append((band, "hull", colors.LIMESTONE, atlas.solid("plain")(band)))
    return parts
