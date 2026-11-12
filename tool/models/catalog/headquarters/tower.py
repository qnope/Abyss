"""The headquarters' third tier, the command tower: a lattice of four legs
rooted on the drum's shoulders and closing in over the cupola, braced and
ringed with lamps, a railed platform halfway up, the beacon (node Beacon)
crowning it and the great dish (node Dish) on the gallery; sensor pods
stand guard on the gallery and its rail glows."""

import math

from mathutils import Vector

from catalog import colors
from catalog.headquarters.bridge import GALLERY
from catalog.headquarters.keep import PHASE, SIDES
from catalog.paints import machined
from catalog.parts import Into, fittings, light, place, rails
from workshop import shapes, sweep

FOOT = (0.68, 1.7)  # radius and height at the legs' roots
TOP = (0.14, 3.4)  # radius and height where they close in
PLATFORM = 3.05
BEACON = 3.78
DECK = GALLERY[1] + GALLERY[2]


def _leg_point(angle, t):
    radius = FOOT[0] + (TOP[0] - FOOT[0]) * t
    return Vector((radius * math.cos(angle), radius * math.sin(angle), FOOT[1] + (TOP[1] - FOOT[1]) * t))


def tower(model, group):
    atlas, into = model.atlas, Into(model, group)
    angles = [k * math.pi / 2 for k in range(4)]
    for k, a in enumerate(angles):
        path = [_leg_point(a, t / 4) for t in range(5)]
        leg = sweep.tube(path, [0.034, 0.03, 0.026, 0.022, 0.018], sides=5, cap=False)
        into.add(leg, "hull", machined(colors.HULL_DARK, 80 + k, soot=0.0), atlas.fit("bolt")(leg))
    for t in (0.18, 0.45, 0.72):
        for a in angles:
            place(into, [(shapes.octahedron(0.028), *light(atlas, "cyan"))], tuple(_leg_point(a, t) * 1.0))
        ring = [_leg_point(a, t) for a in angles] + [_leg_point(angles[0], t)]
        brace = sweep.tube(ring, [0.014] * 5, sides=4, cap=False)
        into.add(brace, "hull", colors.LIMESTONE, atlas.solid("plain")(brace))
    for a, b in zip(angles, angles[1:] + angles[:1]):
        for t0, t1 in ((0.0, 0.18), (0.18, 0.45), (0.45, 0.72)):
            cross = sweep.tube([_leg_point(a, t0), _leg_point(b, t1)], [0.01, 0.01], sides=3, cap=False)
            into.add(cross, "hull", colors.METAL_DARK, None)
    _platform(into, atlas)
    _crown(model, group, atlas)
    _gallery(into, atlas)


def _platform(into, atlas):
    plate = shapes.prism(shapes.polygon(8, 0.3, math.pi / 8), 0.045, bevel=0.01, bottom=True)
    into.add(plate.transform((0, 0, PLATFORM)), "hull", machined(colors.HULL, 90, soot=0.0),
             atlas.fit("tread")(plate))
    edge = [(0.27 * math.cos(a), 0.27 * math.sin(a), PLATFORM + 0.045)
            for a in (math.pi / 8 + math.pi * k / 4 for k in range(8))]
    place(into, rails.railing(atlas, edge, 0.1))
    for point in edge:
        place(into, [(shapes.octahedron(0.022).transform((point[0], point[1], PLATFORM + 0.02)),
                      *light(atlas, "cyan"))])
    spar = sweep.tube([(0, 0, PLATFORM), (0, 0, BEACON)], [0.026, 0.016], sides=6, cap=False)
    into.add(spar, "hull", colors.METAL_DARK, None)
    collar = shapes.cylinder(0.17, 0.05, sides=8, bevel=0.008, smooth=False).transform((0, 0, TOP[1] - 0.02))
    into.add(collar, "hull", machined(colors.METAL_DARK, 91, soot=0.0), atlas.fit("bolt")(collar))


def _crown(model, group, atlas):
    place(Into(model, group), fittings.beacon(atlas, 0.075), (0, 0, BEACON))


def _gallery(into, atlas):
    """Four sensor pods on the deck, a lamp on every post of the rail."""
    for angle in (60, 120, 240, 300):
        a = math.radians(angle)
        base = shapes.cylinder(0.13, 0.1, sides=8, bevel=0.01, smooth=False)
        dome = shapes.sphere(0.13, subdivisions=1).transform((0, 0, 0.17))
        band = shapes.cylinder(0.14, 0.03, sides=8, smooth=False).transform((0, 0, 0.09))
        place(into, [(base, "hull", machined(colors.METAL_DARK, 92, soot=0.0), atlas.fit("plate")(base)),
                     (dome, "hull", machined(colors.LIMESTONE, 93, soot=0.0), atlas.tiled("weathered", 0.5)(dome)),
                     (band, *light(atlas, "cyan")),
                     (shapes.octahedron(0.03).transform((0, 0, 0.33)), *light(atlas, "cyan"))],
              (0.88 * math.cos(a), 0.88 * math.sin(a), DECK))
    for k in range(2 * SIDES):
        a = PHASE + math.pi * k / SIDES
        place(into, [(shapes.octahedron(0.02).transform((0, 0, 0.14)), *light(atlas, "cyan"))],
              ((GALLERY[0] - 0.03) * math.cos(a), (GALLERY[0] - 0.03) * math.sin(a), DECK))
