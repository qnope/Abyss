"""The plateau's body: one loft of rings around the deck, from the rim under
the deck's edge out to the lip, down the strata of its sides, then in under
it, a rocky cone that the spire carries on."""

import math

from mathutils import Vector

from catalog.base_island import outline, strata
from catalog.base_island.layout import RAMPART_TO
from workshop import noise
from workshop.geometry import Geometry

SPIRE_TOP = -4.3
SPIRE_RADIUS = 4.1
SEED = 31


def columns():
    """The body's vertices, one column of rings per point around the deck, from
    under the deck's edge out, down and in."""
    return [_rings(q, n) for q, n in outline.perimeter()]


def body(rings):
    """The body's mesh from its [columns]."""
    geometry = Geometry()
    count, depth = len(rings), len(rings[0])
    for column in rings:
        geometry.verts += column
    for j in range(count):
        k = (j + 1) % count
        for i in range(depth - 1):
            a, b = j * depth + i, k * depth + i
            geometry.faces.append((a, a + 1, b + 1, b))
    geometry.smooth = [True] * len(geometry.faces)
    return geometry


def grout():
    """The bed under the deck's tiles, seen through their seams."""
    h = 6.0
    return Geometry([(-h, -h, -0.06), (h, -h, -0.06), (h, h, -0.06), (-h, h, -0.06)],
                    [(0, 1, 2, 3)])


def _rings(q, n):
    m = outline.margin(q, n)
    lip = q + n * m
    ring = []

    def at(d, z, toward=None, blend=0.0):
        p = q + n * d
        if toward is not None:
            p = p.lerp(toward, blend)
        ring.append(Vector((p.x, p.y, z)))

    at(0.0, -0.06)
    start = RAMPART_TO + 0.06
    for d in (0.05, start, *(start + (m - 0.1 - start) * t for t in (0.3, 0.6, 0.85)), m - 0.1):
        at(d, outline.rim_height(q, n, d))
    at(m - 0.02, outline.rim_height(q, n, m) - 0.03)
    at(m + 0.04, -0.12)
    at(m + 0.07, -0.22)
    fold = strata.tilt(lip.x, lip.y)
    for index, (top, bottom, out, _) in enumerate(strata.BANDS):
        shift = out + 0.09 * noise.value(lip * 0.55, SEED + index)
        g = strata.GROOVE / 2
        top, bottom = top + fold * (index > 0), bottom + fold
        for z, extra in ((top - g, 0.0), (bottom + g, -0.035)):
            column = 0.05 * noise.cells(Vector((lip.x, lip.y, z * 0.15)), SEED + index, 1.6)
            crack = 0.07 * noise.cracks(Vector((lip.x, lip.y, z * 0.3)), SEED, 1.3, 0.2)
            at(m + 0.07 + 0.06 * z + shift + extra + column - crack, z)
        if index < len(strata.BANDS) - 1:
            at(m + 0.07 + 0.06 * bottom - 0.06, bottom)
    angle = math.atan2(lip.y, lip.x)
    circle = Vector((math.cos(angle), math.sin(angle)))
    lumps = noise.fbm(lip * 0.5, SEED + 20)
    sag = 0.35 * max(0.0, noise.fbm(lip * 0.35, SEED + 21))
    at(m - 0.35 + 0.15 * lumps, -2.75 + fold - sag * 0.5)
    at(m - 1.1, -3.15 - sag, circle * 6.2, 0.35 + 0.1 * lumps)
    at(m - 2.0, -3.65 - sag * 0.8, circle * (5.0 + 0.4 * lumps), 0.7)
    ring.append((circle * SPIRE_RADIUS).to_3d() + Vector((0, 0, SPIRE_TOP)))
    return ring
