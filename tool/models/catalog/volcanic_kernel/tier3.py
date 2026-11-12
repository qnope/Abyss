"""Tier 3 of the volcanic kernel, its crown (level 8 and up): six arching
prongs of obsidian closing over the core, a flame of molten rock on the apex
(the node Flame), a ring of lava turning round the second orb, broad lava
falls down the mound, a moat of fire at its foot and shards of basalt
floating in the heat."""

import math

from catalog import colors
from catalog.parts import Into, place
from catalog.parts.deep import BASALT, BASALT_LIGHT, around, lamp, paint_basalt, ring_tube
from catalog.volcanic_kernel import mound, tier2
from workshop import shapes, sweep

OBSIDIAN = (0.02, 0.018, 0.03)
APEX = 2.12


def tier3(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    for k, (x, y, a) in enumerate(around(6, tier2.PILLAR_R, phase=math.radians(30))):
        _prong(into, atlas, a, k)
    _flame(model, group, atlas)
    ring = ring_tube(0.34, 0.022, sides=6, points=32, tilt=(math.radians(22), math.radians(8), 0))
    ring.transform((0, 0, 1.3))
    into.add(ring, "lamp", colors.LAMP, atlas.solid("molten")(ring))
    for k in range(3):
        mound_falls = math.radians(10 + 120 * k)
        mound._flow(into, atlas, mound_falls, 0.2, "molten")
    moat = ring_tube(1.0, 0.03, sides=6, points=40).transform((0, 0, 0.04))
    into.add(moat, "lamp", colors.LAMP, atlas.solid("lava")(moat))
    for k in range(7):
        _shard(into, atlas, rng, k)


def _prong(into, atlas, azimuth, k):
    """An obsidian horn from a pillar's top, arching in to the apex."""
    top = tier2.HEIGHTS[k] + mound.RIM
    path = [(0.46, top - 0.05), (0.43, top + 0.25), (0.3, top + 0.5), (0.14, top + 0.65), (0.03, APEX - 0.05)]
    points = [(r * math.cos(azimuth), r * math.sin(azimuth), z) for r, z in path]
    horn = sweep.tube(points, [0.065, 0.055, 0.045, 0.032, 0.012], sides=5)
    horn.sharp_angle = math.radians(60)
    into.add(horn, "reef", paint_basalt(40 + k, OBSIDIAN, BASALT, warm=1.0), atlas.tiled("basalt", 0.5)(horn))
    place(into, lamp(atlas, "lava", 0.03), points[1])


def _flame(model, group, atlas):
    """A teardrop of fire on the apex, tongues licking round it."""
    piece = model.piece(f"{group}/Flame", (0, 0, APEX - 0.6))
    drop = sweep.lathe([(0.0, 0.0), (0.12, 0.05), (0.17, 0.18), (0.13, 0.36), (0.06, 0.52), (0.0, 0.66)], sides=10)
    parts = [(drop, "lamp", colors.LAMP, atlas.solid("molten")(drop))]
    for k in range(4):
        a = math.pi / 2 * k + 0.4
        tongue = sweep.lathe([(0.0, 0.0), (0.06, 0.08), (0.04, 0.22), (0.0, 0.36)], sides=6)
        tongue.transform((0.12 * math.cos(a), 0.12 * math.sin(a), 0.1), (0.35 * math.sin(a), -0.35 * math.cos(a), 0))
        parts.append((tongue, "lamp", colors.LAMP, atlas.solid("molten")(tongue)))
    place(piece, parts)


def _shard(into, atlas, rng, k):
    """A splinter of basalt hanging in the air, lit from below."""
    a, r, z = rng.uniform(0, 2 * math.pi), rng.uniform(0.62, 0.85), rng.uniform(0.95, 1.75)
    shard = shapes.octahedron(0.07).transform((r * math.cos(a), r * math.sin(a), z),
                                              (rng.uniform(0, 3), rng.uniform(0, 3), rng.uniform(0, 3)),
                                              (0.8, 0.8, 1.8))
    into.add(shard, "reef", paint_basalt(60 + k, BASALT, BASALT_LIGHT, warm=1.0), atlas.solid("plain")(shard))
    place(into, lamp(atlas, "ember", 0.02), (r * math.cos(a), r * math.sin(a), z - 0.12))
