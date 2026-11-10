"""Where the corners of a face land in a tile, as (s, t) in [0, 1]: s to the
right and t up, seen from outside the face. The atlas turns them into UVs."""

import math

import bpy  # noqa: F401, loads mathutils
from mathutils import Vector


def fit(geometry, up=(0, 0, 1)):
    """Each flat facet stretched over the whole tile, upright: [up]
    (projected on it) goes up the tile; a facet across it takes the y axis
    as up. A facet is a face, or the faces lying in the same plane, as a
    flat side cut in a grid: they share the tile."""
    planes, facets = [], {}
    for index in range(len(geometry.faces)):
        normal = geometry.face_normal(index)
        upward = Vector(up)
        if abs(normal.dot(upward.normalized())) > 0.98:
            upward = Vector((0, 1, 0)) if abs(normal.y) < 0.98 else Vector((0, 0, 1))
        upward = (upward - normal * upward.dot(normal)).normalized()
        right = upward.cross(normal)
        points = [(geometry.verts[i].dot(right), geometry.verts[i].dot(upward))
                  for i in geometry.faces[index]]
        offset = geometry.verts[geometry.faces[index][0]].dot(normal)
        key = tuple(round(c, 3) for c in (*normal, offset))
        planes.append((key, points))
        facets.setdefault(key, []).extend(points)
    boxes = {key: _box(points) for key, points in facets.items()}
    return [_normalized(points, boxes[key]) for key, points in planes]


def planar(geometry, right, upward):
    """Every corner of [geometry] projected on the plane of [right] and
    [upward], the whole geometry stretched over the tile: a decal."""
    right, upward = Vector(right), Vector(upward)
    points = [(v.dot(right), v.dot(upward)) for v in geometry.verts]
    flat = _normalized(points, _box(points))
    return [[flat[i] for i in face] for face in geometry.faces]


def tiled(geometry, index, period):
    """The face projected on the world plane it faces most, in periods of
    the seamless pattern, shifted by whole periods into [0, 2]: neighbours
    facing the same way meet without a seam. Gives (s, t) in [0, 1]."""
    normal = geometry.face_normal(index)
    axis = max(range(3), key=lambda a: abs(normal[a]))
    sign = 1 if normal[axis] > 0 else -1
    if axis == 2:
        project = lambda v: (sign * v.x, v.y)  # noqa: E731
    elif axis == 0:
        project = lambda v: (sign * v.y, v.z)  # noqa: E731
    else:
        project = lambda v: (-sign * v.x, v.z)  # noqa: E731
    points = [tuple(c / period for c in project(geometry.verts[i])) for i in geometry.faces[index]]
    result = []
    for a in (0, 1):
        low, high = min(p[a] for p in points), max(p[a] for p in points)
        shift = math.floor(low) if high - math.floor(low) <= 2 else low
        squeeze = 2 / (high - low) if high - low > 2 else 1.0
        result.append([(p[a] - shift) * squeeze / 2 for p in points])
    return list(zip(*result))


def _box(points):
    low = [min(p[a] for p in points) for a in (0, 1)]
    span = [max(max(p[a] for p in points) - low[a], 1e-9) for a in (0, 1)]
    return low, span


def _normalized(points, box):
    low, span = box
    return [((p[0] - low[0]) / span[0], (p[1] - low[1]) / span[1]) for p in points]
