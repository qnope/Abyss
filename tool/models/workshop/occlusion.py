"""Ambient occlusion baked into the vertex colours: each corner is darkened
by how much of its sky the model hides, which gives the contact shading a
mobile renderer cannot afford at run time."""

import math
from dataclasses import dataclass

import bpy  # noqa: F401, loads mathutils
import numpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree

from workshop.materials import COLOR_ATTRIBUTE


@dataclass(frozen=True)
class Occlusion:
    """[rays] per corner, cast up to [distance]; a corner fully hidden keeps
    [floor] of its colour. [sky] > 0 favours the rays going up, as the light
    falls from the surface."""

    rays: int = 24
    distance: float = 1.2
    floor: float = 0.25
    sky: float = 0.35

    def bake(self, objects):
        """Darkens the colours of [objects] by what all of them hide."""
        tree = _tree(objects)
        directions = _hemisphere(self.rays)
        for obj in objects:
            self._bake_object(obj, tree, directions)

    def _bake_object(self, obj, tree, directions):
        mesh = obj.data
        corners = len(mesh.loops)
        if not corners:
            return
        matrix, turn = obj.matrix_world, obj.matrix_world.to_3x3()
        vertex_of = numpy.zeros(corners, dtype=numpy.int32)
        mesh.loops.foreach_get("vertex_index", vertex_of)
        normals = numpy.zeros(corners * 3, dtype=numpy.float32)
        mesh.corner_normals.foreach_get("vector", normals)
        colors = numpy.zeros(corners * 4, dtype=numpy.float32)
        attribute = mesh.color_attributes[COLOR_ATTRIBUTE]
        attribute.data.foreach_get("color", colors)
        cache = {}
        for corner in range(corners):
            n = normals[corner * 3:corner * 3 + 3]
            key = (int(vertex_of[corner]), round(float(n[0]), 2), round(float(n[1]), 2),
                   round(float(n[2]), 2))
            if key not in cache:
                position = matrix @ mesh.vertices[key[0]].co
                normal = (turn @ Vector(n)).normalized()
                cache[key] = self._light(tree, position, normal, directions, key[0])
            colors[corner * 4:corner * 4 + 3] *= cache[key]
        attribute.data.foreach_set("color", colors)

    def _light(self, tree, position, normal, directions, salt):
        side = normal.orthogonal().normalized()
        turn = (salt * 2.399963) % (2 * math.pi)
        side = side * math.cos(turn) + normal.cross(side) * math.sin(turn)
        other = normal.cross(side)
        origin = position + normal * 0.004
        seen = weight_sum = 0.0
        for x, y, z in directions:
            ray = side * x + other * y + normal * z
            weight = 1.0 + self.sky * ray.z
            _, _, _, distance = tree.ray_cast(origin, ray, self.distance)
            open_sky = 1.0 if distance is None else (distance / self.distance) ** 2
            seen += weight * open_sky
            weight_sum += weight
        return self.floor + (1 - self.floor) * seen / weight_sum


def _tree(objects):
    verts, polygons = [], []
    for obj in objects:
        base = len(verts)
        verts += [obj.matrix_world @ v.co for v in obj.data.vertices]
        polygons += [[base + i for i in p.vertices] for p in obj.data.polygons]
    return BVHTree.FromPolygons(verts, polygons, epsilon=0.0)


def _hemisphere(count):
    """[count] directions spread over the upper hemisphere, cosine-weighted."""
    golden = math.pi * (3 - math.sqrt(5))
    result = []
    for i in range(count):
        r = math.sqrt((i + 0.5) / count)
        a = i * golden
        result.append((r * math.cos(a), r * math.sin(a), math.sqrt(max(0.0, 1 - r * r))))
    return result
