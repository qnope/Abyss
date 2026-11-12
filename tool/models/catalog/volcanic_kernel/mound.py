"""Tier 1 of the volcanic kernel: the base's own heart of fire. A mound of black
basalt with a crater, the first embers of the core (a small molten orb
sunk in a lake of lava), rivulets of lava running down its flanks, iron bands
clamping it and three small vents."""

import math

from mathutils import Vector

from catalog import colors
from catalog.parts import Into, place
from catalog.parts.deep import BASALT, BASALT_LIGHT, IRON, lamp, paint_basalt, ring_tube, swell
from workshop import shapes, sweep

# The mound's profile (radius, height): the foot, the flanks, the rim, the crater.
PROFILE = [(1.0, -0.02), (0.96, 0.1), (0.8, 0.3), (0.62, 0.5), (0.5, 0.63), (0.44, 0.67),
           (0.4, 0.6), (0.3, 0.53), (0.0, 0.5)]
RIM = 0.6  # where the pillars of tier 2 stand on
FLANK = PROFILE[1:5]  # what the lava runs down
CORE = (0.3, 0.84)  # the orb's radius and its centre's height
VENTS = ((-75, 0.8), (-20, 0.84), (200, 0.78))  # azimuth in degrees, distance


def tier1(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    body = swell(sweep.lathe(PROFILE, sides=22), 7, 0.06, 0.11)
    body.verts = [Vector((v.x, v.y, max(v.z, 0.0))) for v in body.verts]  # nothing under the pad
    body.sharp_angle = math.radians(60)
    into.add(body, "reef", paint_basalt(7, BASALT, BASALT_LIGHT, warm=0.8),
             atlas.tiled("basalt", 0.8)(body))
    lake = shapes.cylinder(0.4, 0.02, sides=20, smooth=False).transform((0, 0, 0.51))
    into.add(lake, "lamp", colors.LAMP, atlas.tiled("magma", 0.5)(lake))
    core = shapes.sphere(CORE[0], subdivisions=2).transform((0, 0, CORE[1]), scale=(1, 1, 0.9))
    into.add(core, "lamp", colors.LAMP, atlas.tiled("magma", 0.4)(core))
    for k in range(5):
        _flow(into, atlas, math.radians(-60 + 72 * k) + rng.uniform(-0.15, 0.15), 0.09 + 0.03 * (k % 2))
    for z, r in ((0.2, 0.92), (0.4, 0.74)):
        band = ring_tube(r, 0.035, sides=6, points=32).transform((0, 0, z))
        into.add(band, "hull", IRON, atlas.solid("plain")(band))
    for k, (azimuth, distance) in enumerate(VENTS):
        _vent(into, atlas, math.radians(azimuth), distance, 0.1 + 0.02 * k, 8 + k)
    for k in range(10):
        a, r = rng.uniform(0, 2 * math.pi), rng.uniform(0.55, 0.9)
        height = min(PROFILE[1:4], key=lambda p: abs(p[0] - r))[1]
        place(into, lamp(atlas, rng.choice(("ember", "lava")), 0.022), (r * math.cos(a), r * math.sin(a), height + 0.05))


def _flow(into, atlas, azimuth, width, tile="lava"):
    """A rivulet of lava from the rim to the foot, a hand above the rock."""
    side = Vector((-math.sin(azimuth), math.cos(azimuth), 0))
    path, widths = [], []
    for k, (r, z) in enumerate(FLANK):
        wiggle = 0.03 * math.sin(2.3 * k + azimuth * 3)
        r, z = r * 1.012 + 0.012, z + 0.034
        path.append(Vector((r * math.cos(azimuth), r * math.sin(azimuth), z)) + side * wiggle)
        widths.append(width * (0.8 + 0.5 * math.sin(k * 1.7 + 1)))
    ribbon = sweep.ribbon(path, widths, [side] * len(path))
    into.add(ribbon, "lamp", colors.LAMP, atlas.solid(tile)(ribbon))


def _vent(into, atlas, azimuth, distance, radius, seed):
    """A small cone of basalt on the flank with a glowing mouth."""
    r, z = distance, min(FLANK, key=lambda p: abs(p[0] - distance))[1]
    cone = swell(sweep.lathe([(radius * 1.3, -0.06), (radius * 0.8, 0.12), (radius * 0.55, 0.22),
                              (radius * 0.7, 0.26), (radius * 0.35, 0.24)], sides=8), seed, 0.025, 0.08)
    cone.transform((r * math.cos(azimuth), r * math.sin(azimuth), z))
    into.add(cone, "reef", paint_basalt(seed, BASALT, BASALT_LIGHT, warm=0.9), atlas.tiled("basalt", 0.6)(cone))
    mouth = shapes.cylinder(radius * 0.4, 0.02, sides=8, smooth=False)
    place(into, [(mouth, "lamp", colors.LAMP, atlas.solid("molten")(mouth))],
          (r * math.cos(azimuth), r * math.sin(azimuth), z + 0.245))
