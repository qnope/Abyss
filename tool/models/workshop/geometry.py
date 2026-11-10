"""A piece of mesh in plain lists, which the shapes make and the builders
gather: positions, faces as tuples of vertex indices, and per face whether
it is shaded smooth."""

import bpy  # noqa: F401, loads bmesh and mathutils
import bmesh
from mathutils import Euler, Matrix, Vector


class Geometry:
    def __init__(self, verts=(), faces=(), smooth=False):
        self.verts = [Vector(v) for v in verts]
        self.faces = [tuple(f) for f in faces]
        self.smooth = [smooth] * len(self.faces)

    @classmethod
    def from_bmesh(cls, bm, smooth=False):
        bm.verts.index_update()
        geometry = cls([v.co for v in bm.verts],
                       [[v.index for v in f.verts] for f in bm.faces], smooth)
        bm.free()
        return geometry

    def to_bmesh(self):
        bm = bmesh.new()
        verts = [bm.verts.new(v) for v in self.verts]
        for face, smooth in zip(self.faces, self.smooth):
            bm.faces.new([verts[i] for i in face]).smooth = smooth
        return bm

    @property
    def triangles(self):
        return sum(len(face) - 2 for face in self.faces)

    def transform(self, location=(0, 0, 0), rotation=(0, 0, 0), scale=(1, 1, 1)):
        """Scales, then turns (XYZ Euler angles in radians), then moves it, in
        place; gives it back for chaining."""
        if isinstance(scale, (int, float)):
            scale = (scale, scale, scale)
        return self.apply(Matrix.LocRotScale(Vector(location), Euler(rotation), Vector(scale)))

    def apply(self, matrix):
        flip = matrix.to_3x3().determinant() < 0
        self.verts = [matrix @ v for v in self.verts]
        if flip:
            self.faces = [tuple(reversed(face)) for face in self.faces]
        return self

    def displace(self, offset):
        """Moves each vertex by [offset](position), in place."""
        self.verts = [v + Vector(offset(v)) for v in self.verts]
        return self

    def extend(self, other):
        """Adds the faces of [other] to this one, in place."""
        base = len(self.verts)
        self.verts += [v.copy() for v in other.verts]
        self.faces += [tuple(i + base for i in face) for face in other.faces]
        self.smooth += other.smooth
        return self

    def face_normal(self, index):
        points = [self.verts[i] for i in self.faces[index]]
        normal = Vector((0, 0, 0))
        for a, b in zip(points, points[1:] + points[:1]):
            normal += a.cross(b)
        return normal.normalized() if normal.length > 1e-12 else Vector((0, 0, 1))

    def bounds(self):
        low = Vector([min(v[a] for v in self.verts) for a in range(3)])
        high = Vector([max(v[a] for v in self.verts) for a in range(3)])
        return low, high
