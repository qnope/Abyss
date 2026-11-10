"""Gathers faces into one Blender object: their materials and the colour of
each corner, which the vertex colour attribute carries to the glb."""

import math

import bpy

from workshop.materials import COLOR_ATTRIBUTE

# Faces shaded smooth still get a hard edge where they meet at more than this.
SHARP_ANGLE = math.radians(42)


class MeshBuilder:
    def __init__(self):
        self.verts, self.faces, self.smooth = [], [], []
        self.colors, self.face_materials, self.materials = [], [], []

    @property
    def triangles(self):
        return sum(len(face) - 2 for face in self.faces)

    def add(self, geometry, material, paint):
        """Adds [geometry] in [material], each corner coloured by [paint]: a
        linear (r, g, b), or a function of the corner's position and of its
        face's normal giving one."""
        if material not in self.materials:
            self.materials.append(material)
        slot = self.materials.index(material)
        base = len(self.verts)
        self.verts += geometry.verts
        for index, face in enumerate(geometry.faces):
            if callable(paint):
                normal = geometry.face_normal(index)
                self.colors += [paint(geometry.verts[i], normal) for i in face]
            else:
                self.colors += [paint] * len(face)
            self.faces.append(tuple(base + i for i in face))
        self.smooth += geometry.smooth
        self.face_materials += [slot] * len(geometry.faces)

    def to_object(self, name, materials):
        """A new object [name] holding the faces, its materials looked up by
        name in [materials]."""
        mesh = bpy.data.meshes.new(name)
        mesh.from_pydata([tuple(v) for v in self.verts], [], self.faces)
        mesh.polygons.foreach_set("use_smooth", self.smooth)
        mesh.polygons.foreach_set("material_index", self.face_materials)
        for material in self.materials:
            mesh.materials.append(materials[material])
        colors = mesh.color_attributes.new(COLOR_ATTRIBUTE, "BYTE_COLOR", "CORNER")
        colors.data.foreach_set("color", [c for color in self.colors for c in (*color, 1.0)])
        mesh.color_attributes.active_color = colors
        mesh.set_sharp_from_angle(angle=SHARP_ANGLE)
        mesh.update()
        return bpy.data.objects.new(name, mesh)
