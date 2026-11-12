"""The parts of a content that wear a holder's colour: banners and rings of
light, in the node Tint. Each is one closed solid of the lamp material in the
neutral white tile, so the game recolours the whole node with one material;
the poles that carry them are plain parts of the Body."""

import math

from catalog import colors
from catalog.parts import extrude
from workshop import shapes


def _lit(atlas, geometry):
    return [(geometry, "lamp", colors.LAMP, atlas.solid("white")(geometry))]


def banner(atlas, width, height, thick=0.016, notch=0.3):
    """A swallow-tailed banner in the plane y = 0 (x across, z up), its pole
    side at x = 0 and its foot at z = 0, facing -y."""
    n = height * notch
    outline = [(0.0, 0.0), (width, 0.0), (width - n, height / 2), (width, height), (0.0, height)]
    flag = shapes.prism(outline, thick, bevel=0.004).transform((0, 0, -thick / 2))
    flag.transform(rotation=(math.pi / 2, 0, 0))
    return _lit(atlas, flag)


def ring(atlas, radius, width=0.05, height=0.03, sides=16):
    """A flat ring of light on z = 0."""
    return _lit(atlas, extrude.collar(radius, width, height, sides=sides))


def pole(atlas, height, radius=0.014, colour=colors.METAL_DARK):
    """A thin mast of dark metal up from z = 0, for a banner of the Tint."""
    mast = shapes.cylinder(radius, height, sides=6, smooth=False, bottom=False)
    return [(mast, "hull", colour, atlas.solid("plain")(mast))]
