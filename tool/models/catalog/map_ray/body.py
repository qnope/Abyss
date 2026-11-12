"""The ray's parts: the body and wings in one lens-shaped sheet (a pale belly
under an indigo back with lit spots), skinned across its span, and a thin
tail with a lit bead."""

import math

from mathutils import Vector

from catalog import colors
from workshop import noise, shapes, sweep
from workshop.colors import linear, mix, scale
from workshop.geometry import Geometry

BACK, EDGE, BELLY = linear("#2e3a73"), linear("#6c86d6"), linear("#aab4d8")
SPOTS = ((0.0, 0.1), (0.0, 0.0), (-0.1, 0.03), (0.1, 0.03), (-0.2, -0.04), (0.2, -0.04))
COLUMNS, ROWS = 14, 8
HALF, LONG = 0.36, 0.25


def _point(i, j, side):
    """The vertex of column [i], row [j] of a lens: a diamond planform with
    swept tips, thick in the middle, [side] +1 for the back, -1 for the belly."""
    u = i / COLUMNS * 2 - 1
    v = j / ROWS * 2 - 1
    width = HALF * max(0.0, 1.0 - abs(v) ** 1.7) ** 0.8
    x = u * width
    y = v * LONG - 0.12 * abs(u) ** 1.6 * (1 - abs(v)) - 0.02
    thick = 0.05 * (1 - abs(u)) ** 1.2 * max(0.0, 1.0 - abs(v) ** 2) + 0.004
    return Vector((x, y, side * thick * (1.0 if side > 0 else 0.55)))


def _sheet():
    geometry = Geometry(smooth=True)
    for side in (1, -1):
        for j in range(ROWS + 1):
            for i in range(COLUMNS + 1):
                geometry.verts.append(_point(i, j, side))
    row = COLUMNS + 1
    for side, base in ((1, 0), (-1, (ROWS + 1) * row)):
        for j in range(ROWS):
            for i in range(COLUMNS):
                a = base + j * row + i
                quad = (a, a + 1, a + row + 1, a + row)
                geometry.faces.append(quad if side > 0 else tuple(reversed(quad)))
    geometry.smooth = [True] * len(geometry.faces)
    geometry.sharp_angle = math.radians(95)
    return geometry


def wings(model, group, weights):
    """Body and wings: [weights] is {-1: left, 1: right}, each a blend of the
    body and that wing's bones."""
    sheet = _sheet()

    def paint(p, normal):
        edge = min(1.0, abs(p.x) / HALF) ** 2
        if normal.z < 0:
            return scale(mix(BELLY, EDGE, edge * 0.3), 0.95)
        mottle = 1 + 0.15 * noise.fbm(p * 8, 7, octaves=2)
        return scale(mix(BACK, EDGE, edge * 0.7), mottle)

    def blend(p):
        return weights[-1 if p.x < 0 else 1](p)
    model.add(group, sheet, "coral", paint, bone=blend)
    for x, y in SPOTS:
        z = _point(round((x / HALF + 1) / 2 * COLUMNS), round((y / LONG + 1) / 2 * ROWS), 1).z
        spot = shapes.octahedron(0.016).transform((x, y - 0.02, z + 0.004), scale=(1, 1.4, 0.5))
        model.add(group, spot, "glow", colors.GLOW_CYAN, bone=blend)


def tail(model, group, weights, points):
    """The thin tail behind the body, blended along its bones, a lit bead at
    its end."""
    path = [Vector(p) + Vector((0, 0.02, 0)) for p in points] + [Vector((0, points[-1][1] - 0.04, 0))]
    strand = sweep.tube(path, [0.017, 0.012, 0.008, 0.005, 0.003], sides=4)
    model.add(group, strand, "coral", scale(BACK, 1.1), bone=weights)
    bead = shapes.octahedron(0.014).transform(path[-1])
    model.add(group, bead, "glow", colors.GLOW_CYAN, bone=weights)
