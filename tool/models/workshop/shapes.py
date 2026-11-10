"""Primitive shapes as Geometry. Each stands on z = 0, centred on the z axis,
but the spheres, centred on the origin."""

import math

import bpy  # noqa: F401, loads bmesh
import bmesh
from mathutils import Vector

from workshop.geometry import Geometry


def box(size, bevel=0.0, segments=1, smooth=False, bottom=True):
    """A box of [size] (x, y, z), its edges rounded by [bevel]."""
    x, y, _ = size
    outline = [(-x / 2, -y / 2), (x / 2, -y / 2), (x / 2, y / 2), (-x / 2, y / 2)]
    return prism(outline, size[2], bevel, segments, smooth=smooth, bottom=bottom)


def prism(outline, height, bevel=0.0, segments=1, top=1.0, smooth=False, bottom=True):
    """The polygon [outline] (x, y points, counter-clockwise) raised to
    [height], its top scaled by [top] around the axis, its edges bevelled.
    Without [bottom], it is open below, for what stands on something: no
    face nor bevel is spent where nobody looks."""
    bm = bmesh.new()
    low = [bm.verts.new((x, y, 0.0)) for x, y in outline]
    upper = [bm.verts.new((x * top, y * top, height)) for x, y in outline]
    n = len(outline)
    if bottom:
        bm.faces.new(list(reversed(low)))
    bm.faces.new(upper)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new([low[i], low[j], upper[j], upper[i]])
    if bevel > 0:
        edges = [e for e in bm.edges if bottom or not all(v.co.z == 0.0 for v in e.verts)]
        bmesh.ops.bevel(bm, geom=edges, offset=bevel, segments=segments,
                        profile=0.5, affect="EDGES", clamp_overlap=True)
    return Geometry.from_bmesh(bm, smooth)


def polygon(sides, radius, phase=0.0):
    """The outline of a regular polygon, counter-clockwise."""
    return [(radius * math.cos(phase + 2 * math.pi * i / sides),
             radius * math.sin(phase + 2 * math.pi * i / sides)) for i in range(sides)]


def chamfered_square(side, chamfer):
    """The outline of a square of [side] whose corners are cut by [chamfer]."""
    h, c = side / 2, chamfer
    return [(-h + c, -h), (h - c, -h), (h, -h + c), (h, h - c),
            (h - c, h), (-h + c, h), (-h, h - c), (-h, -h + c)]


def cylinder(radius, height, sides=16, top_radius=None, bevel=0.0, segments=1, smooth=True,
             bottom=True):
    top = 1.0 if top_radius is None else top_radius / radius
    return prism(polygon(sides, radius), height, bevel, segments, top, smooth, bottom)


def sphere(radius, subdivisions=2, smooth=True):
    """An icosphere: even triangles, good to deform into rocks and heads."""
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subdivisions, radius=radius)
    geometry = Geometry.from_bmesh(bm, smooth)
    geometry.sharp_angle = math.radians(95)
    return geometry


def octahedron(radius):
    """The cheapest round dot: 8 triangles."""
    v = [(radius, 0, 0), (-radius, 0, 0), (0, radius, 0), (0, -radius, 0),
         (0, 0, radius), (0, 0, -radius)]
    faces = [(0, 2, 4), (2, 1, 4), (1, 3, 4), (3, 0, 4),
             (2, 0, 5), (1, 2, 5), (3, 1, 5), (0, 3, 5)]
    return Geometry(v, faces, smooth=False)


def flatten_below(geometry, floor=0.0, squash=0.3):
    """Pulls what lies under [floor] up toward it, for rocks that sit."""
    geometry.verts = [Vector((v.x, v.y, floor + (v.z - floor) * squash)) if v.z < floor else v
                      for v in geometry.verts]
    return geometry
