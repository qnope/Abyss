"""The rim of the map: the sea floor round the slab the grid stands on,
falling away into the abyss. A loft of one cross-section, from the slab's
edge outward: a sandy shelf, a shoulder, then a cliff in ledges going down
into the dark. An edge runs along x (the straight piece the game repeats
round the map); a corner turns the same section a quarter round the map's
corner. Blender's frame: the slab edge on y = 0, the map at y > 0, outward
-y (in Godot, +z: the front); z up, the grid's top at z = 0."""

import math

from mathutils import Vector

from workshop import noise
from workshop.colors import mix, scale
from workshop.geometry import Geometry

LENGTH = 2.0  # of an edge piece, along x
COLUMNS = 8
# The section: (out, z) from under the slab's edge to the dark below.
SECTION = ((-0.1, -0.06), (0.0, -0.09), (0.5, -0.1), (1.0, -0.13), (1.5, -0.2), (1.85, -0.55),
           (2.1, -1.15), (2.35, -1.65), (2.7, -1.75), (2.95, -2.55), (3.4, -3.45), (3.8, -4.7),
           (4.4, -6.2))
SHELF = 1.5  # where the shelf ends: its out distance


def bump(x, y, seed, scale_=1.0):
    return noise.fbm((x * scale_, y * scale_, 0.0), seed, octaves=3)


def section_at(k, along, seed, swell):
    """The out distance and height of the section's point [k] at [along]
    the rim, roughened by [swell] (0 at the ends of a piece, so that the
    pieces meet on the bare section)."""
    out, z = SECTION[k]
    deep = k >= 4
    out += swell * (0.28 * bump(along, z, seed, 0.9) if deep else 0.0)
    z += swell * (0.07 if k < 5 else 0.2) * bump(along, out * 2, seed + 3, 1.3)
    return out, z


def loft(columns):
    """A mesh from [columns], lists of Vectors (the same count each), joined
    side by side; the faces face up and outward."""
    geometry = Geometry(smooth=True)
    rows = len(columns[0])
    for column in columns:
        geometry.verts += column
    for j in range(len(columns) - 1):
        for i in range(rows - 1):
            a, b = j * rows + i, (j + 1) * rows + i
            geometry.faces.append((a, a + 1, b + 1, b))
    geometry.smooth = [True] * len(geometry.faces)
    geometry.sharp_angle = math.radians(62)
    return geometry


def edge(seed):
    """A straight piece of rim along x, its middle roughened, as geometry."""
    columns = []
    for j in range(COLUMNS + 1):
        x = (j / COLUMNS - 0.5) * LENGTH
        swell = math.sin(math.pi * j / COLUMNS) ** 1.5
        column = []
        for k in range(len(SECTION)):
            out, z = section_at(k, x, seed, swell)
            column.append(Vector((x, -out, z)))
        columns.append(column)
    return loft(columns)


def corner(seed):
    """The quarter round the map's corner at the origin, from the south edge
    (outward -y) to the east one (outward +x), roughened in the middle."""
    columns = []
    for j in range(COLUMNS + 1):
        turn = -math.pi / 2 + math.pi / 2 * j / COLUMNS
        swell = math.sin(math.pi * j / COLUMNS) ** 1.5
        column = []
        for k in range(len(SECTION)):
            out, z = section_at(k, turn * 3, seed, swell)
            column.append(Vector((out * math.cos(turn), out * math.sin(turn), z)))
        columns.append(column)
    return loft(columns)


def paint(palette, seed):
    """The colour of a corner of the rim: sand on the shelf, rock banded by
    height below it, darker with depth, in [palette] (sand, rock, band,
    dark): by the point's place on the section, not its normal."""
    sand, rock, band, dark = palette

    def colour(p, normal):
        mottle = 1 + 0.2 * noise.fbm(p * 2.0, seed, octaves=2)
        if p.z > -0.35 and normal.z > 0.5:
            base = mix(rock, sand, min(1.0, max(0.0, (p.z + 0.35) * 4)))
        else:
            layer = 0.5 + 0.5 * math.sin(p.z * 5.0 + 1.5 * noise.value(p * 0.5, seed + 2))
            base = mix(rock, band, max(0.0, layer - 0.5))
        fade = max(0.04, math.exp(p.z * 0.42))
        return mix(dark, scale(base, mottle), fade)
    return colour
