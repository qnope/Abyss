"""Murk: soft translucent domes of water thick with silt, the stuff of the
fog over the cells not seen. A dome is rings of vertices round a centre,
lumpy, rising from a rim that is fully transparent to a core that is nearly
opaque, so that its edge dissolves into whatever lies beside it. The alpha
is the fourth channel of the vertex colours (the material is translucent)."""

import math

from mathutils import Vector

from workshop import noise
from workshop.colors import mix
from workshop.geometry import Geometry

RINGS = (0.0, 0.38, 0.72, 1.0)
SEGMENTS = 14


def dome(radius, height, seed, core, rim, alphas=(0.8, 0.8, 0.55, 0.0), lumps=0.45):
    """A dome [radius] wide and [height] high at its centre, lumped by [lumps]
    (a share of its height), as (geometry, colours): [core] at its heart to
    [rim] at its edge, with the [alphas] of its rings."""
    verts, colours, faces = [], [], []
    for r, alpha in zip(RINGS, alphas):
        count = 1 if r == 0.0 else SEGMENTS
        for k in range(count):
            a = 2 * math.pi * k / SEGMENTS
            x, y = math.cos(a) * r * radius, math.sin(a) * r * radius
            lump = 1 + lumps * noise.fbm((x * 1.2, y * 1.2, 0.0), seed, octaves=2)
            z = height * (1 - r ** 4) * lump
            verts.append(Vector((x, y, z)))
            colours.append((*mix(core, rim, r), alpha))
    start = [0, 1, 1 + SEGMENTS, 1 + 2 * SEGMENTS]
    for k in range(SEGMENTS):
        n = (k + 1) % SEGMENTS
        faces.append((0, start[1] + k, start[1] + n))
        for ring in (1, 2):
            a, b = start[ring], start[ring + 1]
            faces.append((a + k, b + k, b + n, a + n))
    geometry = Geometry(verts, faces, smooth=True)
    corners = [[colours[i] for i in face] for face in faces]
    return geometry, corners


def sheet(half, seed, low, high, alpha, fade, rise=0.04, cells=8):
    """A flat sheet of murk over a square [half] * 2 wide, as (geometry,
    colours): its top gently undulating by [rise], mottled between [low] and
    [high], opaque as [alpha] inside and fading to nothing over [fade] at its
    border, so that two sheets side by side blend into one blanket."""
    verts, colours, faces = [], [], []
    for j in range(cells + 1):
        for i in range(cells + 1):
            x, y = (i / cells * 2 - 1) * half, (j / cells * 2 - 1) * half
            mottle = 0.5 + 0.5 * noise.fbm((x * 2.2, y * 2.2, 0.0), seed, octaves=2)
            edge = (half - max(abs(x), abs(y))) / fade
            fall = min(max(edge, 0.0), 1.0)
            verts.append(Vector((x, y, rise * noise.fbm((x * 1.8, y * 1.8, 1.0), seed + 5))))
            colours.append((*mix(low, high, mottle), alpha * fall * fall * (3 - 2 * fall)))
    for j in range(cells):
        for i in range(cells):
            a = j * (cells + 1) + i
            faces.append((a, a + 1, a + cells + 2, a + cells + 1))
    return Geometry(verts, faces, smooth=True), [[colours[i] for i in face] for face in faces]
