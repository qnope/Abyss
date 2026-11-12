"""Tier 3 of the pressure capsule, its crown: two gimbal rings in white steel
round the hull on four pivot posts, studded with cyan lights, two seams of
light at the equator, a mast with a strobe (the node Beacon) on the hatch, a
drill arm on the plinth, and more reef."""

import math

from catalog import colors
from catalog.paints import machined
from catalog.parts import Into, fittings, light, place, reef
from catalog.parts.deep import STEEL, STEEL_DEEP, WHITE, beam, lamp, ring_tube
from catalog.pressure_capsule import layout
from catalog.pressure_capsule.layout import CENTRE, RADIUS
from workshop import shapes, sweep

GIMBAL = 0.88
TILTS = ((math.radians(62), 0, 0), (0, math.radians(-62), 0))
REEF = ((-0.1, -1.04, 0.7), (1.05, 0.2, 0.7), (-1.05, 0.15, 0.6))


def tier3(model, group):
    atlas, into = model.atlas, Into(model, group)
    _gimbals(into, atlas)
    _seams(into, atlas)
    _mast(model, group, into, atlas)
    _drill(into, atlas)
    for x, y, size in REEF:
        reef.cluster(into, model.rng, atlas, (x, y, 0.0), size * 0.8, 2)


def _gimbals(into, atlas):
    for k, tilt in enumerate(TILTS):
        ring = ring_tube(GIMBAL, 0.035, sides=6, points=40, tilt=tilt).transform((0, 0, CENTRE))
        into.add(ring, "hull", machined(WHITE, 70 + k, soot=0.0), atlas.tiled("plates", 0.4)(ring))
        for j in range(8):
            t = 2 * math.pi * j / 8 + math.pi / 8
            node = shapes.octahedron(0.04).transform((GIMBAL * math.cos(t), GIMBAL * math.sin(t), 0))
            node.transform(rotation=tilt).transform((0, 0, CENTRE))
            into.add(node, *light(atlas, "cyan"))
    for a in layout.LEGS:
        foot = (GIMBAL * math.cos(a), GIMBAL * math.sin(a), layout.PLINTH[1] + 0.04)
        top = (GIMBAL * math.cos(a), GIMBAL * math.sin(a), CENTRE)
        place(into, beam(atlas, foot, top, 0.07, STEEL_DEEP, 72, depth=0.07))
        hub = shapes.cylinder(0.055, 0.08, sides=8, smooth=False).transform((0, 0, -0.04))
        place(into, [(hub, "hull", machined(STEEL, 73, soot=0.0), atlas.fit("bolt")(hub))], top)


def _seams(into, atlas):
    for z in (-0.07, 0.07):
        seam = ring_tube(RADIUS + 0.022, 0.012, sides=4, points=32).transform((0, 0, CENTRE + z))
        into.add(seam, *light(atlas, "cyan"))


def _mast(model, group, into, atlas):
    top = CENTRE + RADIUS + 0.08
    place(into, fittings.mast(atlas, 0.42, 0.03, STEEL_DEEP, 80), (0, 0, top))
    beacon = model.piece(f"{group}/Beacon", (0, 0, top + 0.42))
    place(beacon, fittings.beacon(atlas, 0.06, "white", STEEL_DEEP, 81))
    for k in range(3):
        a = 2 * math.pi * k / 3
        place(into, lamp(atlas, "cyan", 0.03), (0.07 * math.cos(a), 0.07 * math.sin(a), top + 0.26))


def _drill(into, atlas):
    base = shapes.cylinder(0.11, 0.1, sides=10, top_radius=0.09, bevel=0.01, smooth=False)
    place(into, [(base, "hull", machined(STEEL_DEEP, 90, soot=0.0), atlas.fit("plate")(base))],
          (0.55, 0.62, layout.PLINTH[1]))
    joints = [(0.55, 0.62, 0.28), (0.82, 0.8, 0.8), (0.95, 0.82, 0.42)]
    place(into, beam(atlas, joints[0], joints[1], 0.07, WHITE, 91) + beam(atlas, joints[1], joints[2], 0.06, WHITE, 92))
    for joint in joints[1:2]:
        knuckle = shapes.sphere(0.07, subdivisions=1).transform(joint)
        place(into, [(knuckle, "hull", machined(STEEL_DEEP, 93, soot=0.0), atlas.solid("plain")(knuckle))])
    bit = sweep.lathe([(0.07, 0.0), (0.05, -0.08), (0.0, -0.22)], sides=8, smooth=False)
    place(into, [(bit, "hull", colors.METAL_DARK, atlas.fit("bolt")(bit))], joints[2])
