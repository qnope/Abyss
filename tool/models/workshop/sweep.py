"""Shapes swept along a path or turned around an axis: branches, roots and
veins (tubes), leaves and strands (ribbons), vases and cups (lathes)."""

import math

ORGANIC = math.radians(95)

import bpy  # noqa: F401, loads mathutils
from mathutils import Vector

from workshop.geometry import Geometry


def frames(points):
    """A tangent and two normals at each point of the path, turned as little
    as possible from one point to the next (parallel transport)."""
    points = [Vector(p) for p in points]
    tangents = []
    for i in range(len(points)):
        a, b = points[max(i - 1, 0)], points[min(i + 1, len(points) - 1)]
        tangents.append((b - a).normalized())
    side = tangents[0].cross(Vector((0, 0, 1)))
    if side.length < 1e-4:
        side = tangents[0].cross(Vector((1, 0, 0)))
    side.normalize()
    result = []
    for i, tangent in enumerate(tangents):
        if i:
            side = (side - tangent * side.dot(tangent)).normalized()
        result.append((tangent, side, tangent.cross(side)))
    return result


def tube(points, radii, sides=6, cap=True, smooth=True):
    """A tube along [points], [radii] wide at each; its start is open (it
    grows from something) and its end closed by a point when [cap]."""
    geometry = Geometry()
    ring = []
    for point, radius, (_, side, up) in zip(points, radii, frames(points)):
        ring.append(len(geometry.verts))
        for k in range(sides):
            a = 2 * math.pi * k / sides
            geometry.verts.append(Vector(point) + (side * math.cos(a) + up * math.sin(a)) * radius)
    for r in range(len(points) - 1):
        for k in range(sides):
            j = (k + 1) % sides
            geometry.faces.append((ring[r] + k, ring[r] + j, ring[r + 1] + j, ring[r + 1] + k))
    if cap:
        tip = len(geometry.verts)
        geometry.verts.append(Vector(points[-1]) + frames(points)[-1][0] * radii[-1] * 0.6)
        geometry.faces += [(ring[-1] + k, ring[-1] + (k + 1) % sides, tip) for k in range(sides)]
    geometry.smooth = [smooth] * len(geometry.faces)
    geometry.sharp_angle = ORGANIC
    return geometry


def ribbon(points, widths, sides=None):
    """A flat strip along [points], [widths] wide, spread along [sides] (the
    path's own normal when None): a leaf, a strand of algae."""
    geometry = Geometry()
    path_frames = frames(points)
    for i, (point, width) in enumerate(zip(points, widths)):
        side = Vector(sides[i]) if sides else path_frames[i][1]
        geometry.verts += [Vector(point) - side * width / 2, Vector(point) + side * width / 2]
    geometry.faces = [(2 * i, 2 * i + 1, 2 * i + 3, 2 * i + 2) for i in range(len(points) - 1)]
    geometry.smooth = [True] * len(geometry.faces)
    geometry.sharp_angle = ORGANIC
    return geometry


def lathe(profile, sides=12, phase=0.0, smooth=True):
    """The [profile] of (radius, height) points turned around the z axis. A
    point of radius 0 closes the shape there."""
    geometry = Geometry()
    rings = []
    for radius, height in profile:
        if radius <= 1e-6:
            rings.append([len(geometry.verts)])
            geometry.verts.append(Vector((0, 0, height)))
            continue
        rings.append(list(range(len(geometry.verts), len(geometry.verts) + sides)))
        for k in range(sides):
            a = phase + 2 * math.pi * k / sides
            geometry.verts.append(Vector((radius * math.cos(a), radius * math.sin(a), height)))
    for low, high in zip(rings, rings[1:]):
        for k in range(sides):
            j = (k + 1) % sides
            if len(low) == 1:
                geometry.faces.append((low[0], high[j], high[k]))
            elif len(high) == 1:
                geometry.faces.append((low[k], low[j], high[0]))
            else:
                geometry.faces.append((low[k], low[j], high[j], high[k]))
    geometry.smooth = [smooth] * len(geometry.faces)
    geometry.sharp_angle = ORGANIC
    return geometry
