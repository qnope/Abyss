"""Small props that make a building lived in: crates, drums and a badge."""

import math

from catalog import colors
from catalog.paints import machined
from workshop import shapes


def crate(atlas, size, colour=colors.PIPE, seed=0):
    """A riveted crate, a band of hazard stripes around its foot."""
    x, y, z = size
    box = shapes.box(size, bevel=0.008, bottom=False)
    band = shapes.box((x + 0.006, y + 0.006, z * 0.18), bottom=False)
    band.faces = [f for i, f in enumerate(band.faces) if abs(band.face_normal(i).z) < 0.5]
    band.smooth = [False] * len(band.faces)
    return [(box, "hull", machined(colour, seed, soot=0.2, height=0.2), atlas.fit("plate")(box)),
            (band, "hull", colors.WHITE, atlas.fit("hazard")(band))]


def drum(atlas, radius, height, colour=colors.CORAL_ORANGE, seed=0):
    """A barrel with two hoops, its lid lighter."""
    body = shapes.cylinder(radius, height, sides=10, bevel=0.006, bottom=False, smooth=True)
    parts = [(body, "hull", machined(colour, seed, soot=0.3, height=0.2),
              atlas.tiled("weathered", 0.4)(body))]
    for z in (height * 0.22, height * 0.72):
        hoop = shapes.cylinder(radius * 1.04, 0.018, sides=10, bottom=False).transform((0, 0, z))
        parts.append((hoop, "hull", colors.METAL_DARK, atlas.solid("plain")(hoop)))
    return parts


def badge(atlas, radius, tile="emblem"):
    """A round badge in the plane y = 0 facing -y: the colony's emblem."""
    disc = shapes.cylinder(radius, 0.012, sides=12, smooth=False)
    disc.transform(rotation=(math.pi / 2, 0, 0))
    mapped = atlas.planar(tile, (1, 0, 0), (0, 0, 1))(disc)
    return [(disc, "hull", colors.WHITE, mapped)]
