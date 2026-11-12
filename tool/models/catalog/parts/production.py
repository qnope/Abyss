"""Parts the production buildings share: their deck plate, basins, tanks,
spoked wheels and the lit strip around a deck. Each gives its parts as
(geometry, material, paint, uv) in its own frame, standing on z = 0."""

import math

from mathutils import Vector

from catalog import colors
from catalog.paints import machined
from catalog.parts import light, rails, sides_and_top
from workshop import shapes, sweep


def deck(atlas, height=0.09, side=1.56, chamfer=0.22, colour=colors.PAD, strip="cyan", seed=1):
    """The building's deck: a chamfered plate of riveted sides and a tread
    top, a lit strip along its edge, standing on the pad (z = 0)."""
    block = shapes.prism(shapes.chamfered_square(side, chamfer), height, bevel=0.02, top=0.985,
                         bottom=False).subdivide(0.3)
    parts = [(block, "hull", machined(colour, seed, soot=0.3, height=0.12),
              sides_and_top(atlas, block, "plate_wide", "tread"))]
    edge = shapes.prism(shapes.chamfered_square(side * 0.99 + 0.008, chamfer), 0.016, bottom=False)
    edge.faces = [f for i, f in enumerate(edge.faces) if abs(edge.face_normal(i).z) < 0.5]
    edge.smooth = [False] * len(edge.faces)
    parts.append((edge.transform((0, 0, height - 0.035)), *light(atlas, strip)))
    return parts


def basin(atlas, size, height=0.08, tile="pool", colour=colors.HULL, seed=0):
    """A shallow basin of [size] (x, y) with a lit liquid under its rim."""
    w, d = size
    wall = 0.035
    parts = []
    for k, (box, at) in enumerate((((w, wall, height), (0, (d - wall) / 2)),
                                   (((w, wall, height)), (0, -(d - wall) / 2)),
                                   ((wall, d - 2 * wall, height), ((w - wall) / 2, 0)),
                                   ((wall, d - 2 * wall, height), (-(w - wall) / 2, 0)))):
        rim = shapes.box(box, bevel=0.008, bottom=False).transform((*at, 0))
        parts.append((rim, "hull", machined(colour, seed + k, soot=0.2), atlas.fit("plate")(rim)))
    surface = shapes.box((w - 2 * wall + 0.01, d - 2 * wall + 0.01, 0.01), bottom=False)
    surface.faces = [f for i, f in enumerate(surface.faces) if surface.face_normal(i).z > 0.9]
    surface.smooth = [False]
    surface.transform((0, 0, height * 0.7))
    parts.append((surface, "lamp", colors.LAMP, atlas.fit(tile)(surface)))
    return parts


def tank(atlas, radius, height, colour=colors.HULL, sides=14, ladder=True, seed=0):
    """A riveted storage tank: banded, domed, with a ladder on its side."""
    body = shapes.cylinder(radius, height, sides=sides, top_radius=radius * 0.97, smooth=False,
                           bottom=False).subdivide(0.3)
    parts = [(body, "hull", machined(colour, seed, soot=0.35, height=0.3), atlas.fit("plate_tall")(body))]
    for z in (height * 0.28, height * 0.7):
        band = shapes.cylinder(radius * 1.03, 0.04, sides=sides, smooth=False).transform((0, 0, z))
        parts.append((band, "hull", machined(colors.TRIM, seed + 1, soot=0.0), atlas.fit("strap")(band)))
    lid = sweep.lathe([(radius * 0.97, height), (radius * 1.02, height + 0.02),
                       (radius * 0.9, height + 0.045), (radius * 0.45, height + 0.07), (0.0, height + 0.075)],
                      sides=sides, smooth=False)
    parts.append((lid, "hull", machined(colors.HULL_DARK, seed + 2, soot=0.0), atlas.fit("bolt")(lid)))
    if ladder:
        for part in rails.ladder(atlas, height + 0.04, 0.1):
            part[0].transform((0, -radius * 0.98, 0), (0, 0, 0))
            parts.append(part)
    return parts


def wheel(atlas, radius, spokes=6, tube=0.016, colour=colors.HULL_DARK, seed=0):
    """A spoked wheel turning about the y axis: a rim, spokes, a hub."""
    ring = [(radius * math.cos(a), 0, radius * math.sin(a))
            for a in (2 * math.pi * k / 16 for k in range(17))]
    rim = sweep.tube([Vector(p) for p in ring], [tube] * 17, sides=4, cap=False)
    parts = [(rim, "hull", machined(colour, seed, soot=0.0), atlas.solid("plain")(rim))]
    for k in range(spokes):
        a = math.pi * k / spokes
        spoke = shapes.box((radius * 2, tube * 1.2, tube * 1.2)).transform((0, 0, -tube * 0.6))
        spoke.transform(rotation=(0, -a, 0))
        parts.append((spoke, "hull", colour, atlas.solid("plain")(spoke)))
    hub = shapes.cylinder(radius * 0.22, tube * 4, sides=8, bevel=0.004)
    hub.transform((0, -tube * 2, 0), (-math.pi / 2, 0, 0))
    parts.append((hub, "hull", colors.TRIM, atlas.fit("bolt")(hub)))
    return parts


def hopper(atlas, side=0.3, leg=0.3, funnel=0.2, colour=colors.HULL, fill=colors.GROOVE, seed=0):
    """A bin on four legs standing on z = 0: a funnel narrowing downward
    under a rim, open at its top, filled to [fill]'s colour."""
    parts = []
    for sx in (-1, 1):
        for sy in (-1, 1):
            post = shapes.box((0.03, 0.03, leg), bottom=False).transform(
                (sx * side * 0.38, sy * side * 0.38, 0))
            parts.append((post, "hull", colors.METAL_DARK, atlas.solid("plain")(post)))
    h = side / 2
    cone = shapes.prism([(-h, -h), (h, -h), (h, h), (-h, h)], funnel, top=0.3, bevel=0.008, bottom=False)
    cone.transform(rotation=(math.pi, 0, 0)).transform((0, 0, leg + funnel))
    top = leg + funnel
    for sx, sy, w, d in ((0, 1, side + 0.04, 0.03), (0, -1, side + 0.04, 0.03), (1, 0, 0.03, side - 0.02),
                         (-1, 0, 0.03, side - 0.02)):
        wall = shapes.box((w, d, 0.07), bevel=0.006, bottom=False).transform(
            (sx * (side + 0.01) / 2, sy * (side + 0.01) / 2, top - 0.01))
        parts.append((wall, "hull", machined(colors.HULL_DARK, seed + 1, soot=0.0), atlas.fit("strap")(wall)))
    parts.append((cone, "hull", machined(colour, seed, soot=0.3), atlas.fit("plate")(cone)))
    heap = shapes.box((side - 0.03, side - 0.03, 0.01), bottom=False).transform((0, 0, top - 0.035))
    parts.append((heap, "hull", fill, atlas.solid("plain")(heap)))
    return parts
