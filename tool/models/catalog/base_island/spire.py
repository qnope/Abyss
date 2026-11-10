"""The rock spire under the plateau, plunging into the abyss: a twisted,
ribbed column, coarser toward its tip, which the game's fog swallows."""

import math

from mathutils import Vector

from catalog.base_island.body import SPIRE_RADIUS, SPIRE_TOP
from workshop import noise
from workshop.geometry import Geometry

SEED = 23
SIDES = 36
# (height, radius) down the spire: rings further apart as it gets lower.
PROFILE = ((SPIRE_TOP + 0.4, SPIRE_RADIUS + 0.3), (-4.8, 3.8), (-5.4, 3.35), (-6.2, 2.9),
           (-7.2, 2.45), (-8.4, 2.0), (-9.8, 1.55), (-11.4, 1.1), (-13.2, 0.7),
           (-15.2, 0.35), (-17.5, 0.08))


def rings():
    """The spire's vertices, ring by ring from the top."""
    result = []
    for z, radius in PROFILE:
        centre = Vector((0.35 * math.sin(z * 0.23), 0.25 * math.sin(z * 0.31 + 1), 0))
        ring = []
        result.append(ring)
        for k in range(SIDES):
            a = 2 * math.pi * k / SIDES + z * 0.05
            point = Vector((math.cos(a), math.sin(a), 0))
            rib = 0.1 * abs(math.sin(a * 5 + z * 0.35))
            lumps = 0.2 * noise.fbm(point * 1.4 + Vector((0, 0, z * 0.45)), SEED, octaves=3)
            crack = 0.08 * noise.cracks(point * 2 + Vector((0, 0, z * 0.25)), SEED, 1.0, 0.25)
            r = radius * (1 + lumps - rib - crack)
            ring.append(centre + point * r + Vector((0, 0, z)))
    return result


def spire(spire_rings):
    geometry = Geometry()
    for ring in spire_rings:
        geometry.verts += ring
    for i in range(len(spire_rings) - 1):
        for k in range(SIDES):
            j = (k + 1) % SIDES
            a, b = i * SIDES + k, i * SIDES + j
            geometry.faces.append((a, a + SIDES, b + SIDES, b))
    geometry.smooth = [True] * len(geometry.faces)
    return geometry


def stalactite(top, length, radius, seed, sides=10):
    """A smaller spike hanging from the plateau's underside at [top]."""
    geometry = Geometry()
    rings = 6
    for i in range(rings):
        t = i / (rings - 1)
        z = top.z - length * t
        r = radius * (1 - t) ** 0.8 + 0.02
        bend = Vector((0.3 * t * t, -0.2 * t * t, 0)) * length * 0.3
        for k in range(sides):
            a = 2 * math.pi * k / sides
            point = Vector((math.cos(a), math.sin(a), 0))
            wobble = 1 + 0.25 * noise.value(point * 1.5 + Vector((0, 0, t * 3)), seed)
            geometry.verts.append(Vector((top.x, top.y, z)) + bend + point * r * wobble)
    for i in range(rings - 1):
        for k in range(sides):
            j = (k + 1) % sides
            a, b = i * sides + k, i * sides + j
            geometry.faces.append((a, a + sides, b + sides, b))
    geometry.smooth = [True] * len(geometry.faces)
    return geometry
