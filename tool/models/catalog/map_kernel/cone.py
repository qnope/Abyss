"""The volcano's rock: a faceted cone of black basalt with a crater, spurs of
rock down its flanks, lava running from the rim to the foot and rubble round
its base."""

import math

from mathutils import Vector

from catalog import colors
from catalog.parts import extrude
from catalog.parts.deep import BASALT, BASALT_LIGHT, IRON, paint_basalt, ring_tube, swell
from workshop import noise, shapes, sweep

# The cone's profile (radius, height): the foot, the flanks, the rim, the crater.
PROFILE = [(1.0, -0.03), (0.97, 0.05), (0.84, 0.3), (0.66, 0.72), (0.48, 1.18), (0.36, 1.5), (0.3, 1.66),
           (0.34, 1.72), (0.27, 1.72), (0.22, 1.62), (0.0, 1.58)]
RIM = (0.3, 1.7)
FLANK = PROFILE[1:7]


def radius_at(z):
    """The cone's radius at the height [z] on its outer flank."""
    for (r0, z0), (r1, z1) in zip(FLANK, FLANK[1:]):
        if z0 <= z <= z1:
            return r0 + (r1 - r0) * (z - z0) / (z1 - z0)
    return FLANK[-1][0]


def rock(into, atlas, rng):
    body = swell(sweep.lathe(PROFILE, sides=22), 21, 0.07, 0.2)
    body.verts = [Vector((v.x, v.y, max(v.z, 0.0))) for v in body.verts]
    body.sharp_angle = math.radians(55)
    into.add(body, "reef", paint_basalt(21, BASALT, BASALT_LIGHT, warm=1.0), atlas.tiled("basalt", 0.9)(body))
    for k in range(5):  # spurs of rock down the flanks, between the lava
        a = math.radians(36 + 72 * k)
        spur = shapes.prism(extrude_outline(rng), 0.75, bevel=0.02, top=0.25, bottom=False)
        spur.transform((0, 0, 0), (math.radians(15), 0, 0)).transform((0, 0.82, 0.2))
        spur.transform((0, 0, 0), (0, 0, a - math.pi / 2))
        into.add(spur, "reef", paint_basalt(30 + k, BASALT, BASALT_LIGHT, warm=0.6), atlas.tiled("basalt", 0.7)(spur))
    for z, width in ((0.35, 0.05), (0.85, 0.04)):
        r = radius_at(z) * 1.01
        band = ring_tube(r, width, sides=6, points=34).transform((0, 0, z))
        into.add(band, "hull", IRON, atlas.solid("plain")(band))


def extrude_outline(rng):
    return extrude.jagged(rng, 6, 0.12, 0.25)


def flows(into, atlas, count, offset, width, tile="lava"):
    """Rivulets of lava from the foot to the rim, a hand above the rock (the
    strip is wound so that it faces out)."""
    for k in range(count):
        azimuth = offset + 2 * math.pi * k / count
        side = Vector((-math.sin(azimuth), math.cos(azimuth), 0))
        path, widths = [], []
        for j, (r, z) in enumerate(FLANK):
            wiggle = 0.05 * math.sin(2.3 * j + azimuth * 3)
            r, z = r * 1.02 + 0.03, z + 0.02
            path.append(Vector((r * math.cos(azimuth), r * math.sin(azimuth), z)) + side * wiggle)
            widths.append(width * (0.7 + 0.6 * math.sin(j * 1.7 + 1 + k)))
        ribbon = sweep.ribbon(path, widths, [side] * len(path))
        into.add(ribbon, "lamp", colors.LAMP, atlas.solid(tile)(ribbon))


def rubble(into, atlas, rng):
    for k in range(10):
        a = 2 * math.pi * k / 10 + rng.uniform(-0.1, 0.1)
        size = rng.uniform(0.1, 0.18)
        chunk = shapes.sphere(1.0, subdivisions=1)
        chunk.sharp_angle = math.radians(50)
        chunk.displace(lambda p: p.normalized() * 0.25 * noise.fbm(p * 1.7, k))
        chunk.transform((0, 0, 0), scale=(size * 1.2, size, size * 0.7))
        chunk.transform((1.02 * math.cos(a), 1.02 * math.sin(a), 0.0), (0, 0, rng.uniform(0, 6.28)))
        into.add(chunk, "reef", paint_basalt(40 + k, BASALT, BASALT_LIGHT, warm=0.7), atlas.tiled("basalt", 0.6)(chunk))
