"""Openings in a hull: portholes and doors. Each stands in the plane y = 0
facing -y (the front view), centred on x = 0; a door stands on z = 0."""

import math

from catalog import colors
from catalog.paints import machined
from workshop import shapes, sweep
from workshop.geometry import Geometry

_TURN = (math.pi / 2, 0, 0)  # a lathe's axis (z) turned to face -y


def porthole(atlas, radius, tile="porthole_amber", frame=colors.METAL_DARK, seed=0):
    """A round window: a bolted flange around a lit pane, set in the hull."""
    r = radius
    flange = sweep.lathe([(r * 1.42, 0.0), (r * 1.42, 0.022), (r * 1.18, 0.036),
                          (r * 1.04, 0.06), (r * 0.9, 0.055), (r * 0.9, 0.012)],
                         sides=12, phase=math.pi / 12, smooth=False)
    pane = sweep.lathe([(r * 0.92, 0.016), (r * 0.5, 0.024), (0.0, 0.027)], sides=12,
                       phase=math.pi / 12)
    glass_uv = atlas.planar(tile, (1, 0, 0), (0, 1, 0))(pane)
    parts = [(flange, "hull", machined(frame, seed, soot=0.0), atlas.fit("bolt")(flange)),
             (pane, "lamp", colors.LAMP, glass_uv)]
    for geometry, *_ in parts:
        geometry.transform(rotation=_TURN)
    return parts


def door(atlas, width, height, colour=colors.METAL, frame=colors.METAL_DARK, seed=0):
    """A hatch: a frame, a door of two leaves (the atlas' door), a wheel to
    open it, a hazard-striped sill and a lamp above."""
    lintel = shapes.box((width + 0.1, 0.07, height + 0.05), bevel=0.012).transform((0, 0.0, 0))
    leaf = shapes.box((width, 0.03, height), bevel=0.008).transform((0, -0.045, 0.0))
    face = [i for i in range(len(leaf.faces)) if leaf.face_normal(i).y < -0.9]
    leaf_uv = atlas.fit("door")(leaf)
    leaf_uv = [uv if i in face else atlas.solid("plain")(leaf)[i] for i, uv in enumerate(leaf_uv)]
    wheel = Geometry()
    ring = [(0.075 * math.cos(a), 0, 0.075 * math.sin(a))
            for a in (2 * math.pi * k / 10 for k in range(11))]
    wheel.extend(sweep.tube(ring, [0.012] * 11, sides=4, cap=False))
    for a in (0.4, 0.4 + math.pi / 2):
        spoke = shapes.box((0.15, 0.012, 0.014)).transform((0, 0, -0.007), (0, a, 0))
        wheel.extend(spoke)
    wheel.transform((0, -0.075, height * 0.55))
    sill = shapes.box((width + 0.16, 0.12, 0.035), bevel=0.008).transform((0, -0.05, 0))
    hood = shapes.box((0.16, 0.07, 0.035), bevel=0.01).transform((0, -0.06, height + 0.07))
    bulb = shapes.box((0.11, 0.03, 0.025)).transform((0, -0.07, height + 0.045))
    paint = machined(colour, seed, soot=0.2)
    return [(lintel, "hull", machined(frame, seed, soot=0.2), atlas.fit("plate_tall")(lintel)),
            (leaf, "hull", paint, leaf_uv),
            (wheel, "hull", colors.LIMESTONE, atlas.solid("plain")(wheel)),
            (sill, "hull", colors.WHITE, atlas.fit("hazard")(sill)),
            (hood, "hull", machined(frame, seed), atlas.solid("plain")(hood)),
            (bulb, "lamp", colors.LAMP, atlas.solid("amber")(bulb))]
