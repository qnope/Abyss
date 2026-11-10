"""Gathers faces into one Blender object: their materials, the colour of
each corner, which the vertex colour attribute carries to the glb, and,
for a model with an atlas, each corner's place in it (UV)."""

import bpy

from workshop.materials import COLOR_ATTRIBUTE


class MeshBuilder:
    """[blank] maps the faces added without a mapping into the atlas (its
    white tile); None for a model without atlas, whose mesh has no UV."""

    def __init__(self, blank=None):
        self.verts, self.faces, self.smooth = [], [], []
        self.colors, self.face_materials, self.materials = [], [], []
        self.sharp, self.uvs, self.blank = [], [], blank

    @property
    def triangles(self):
        return sum(len(face) - 2 for face in self.faces)

    def add(self, geometry, material, paint, uv=None):
        """Adds [geometry] in [material], each corner coloured by [paint]: a
        linear (r, g, b), or a function of the corner's position and of its
        face's normal giving one. [uv] maps its faces into the atlas: one of
        Atlas' mappings, or what one gave (a part maps itself before it is
        turned into place); the white tile without it."""
        if uv is not None and self.blank is None:
            raise ValueError("a mapping into an atlas, but the model has none")
        if self.blank is not None:
            corners = (uv or self.blank)(geometry) if uv is None or callable(uv) else uv
            if len(corners) != len(geometry.faces):
                raise ValueError("a mapping of another geometry")
            self.uvs += [c for face in corners for c in face]
        if material not in self.materials:
            self.materials.append(material)
        slot = self.materials.index(material)
        base = len(self.verts)
        self.sharp += [(a + base, b + base) for a, b in geometry.sharp_edges()]
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
        if self.blank is not None:
            mesh.uv_layers.new(name="UVMap").data.foreach_set(
                "uv", [c for corner in self.uvs for c in corner])
        mesh.update()
        index = {edge.key: edge.index for edge in mesh.edges}
        flags = [False] * len(mesh.edges)
        for edge in self.sharp:
            flags[index[edge]] = True
        mesh.attributes.new("sharp_edge", "BOOLEAN", "EDGE").data.foreach_set("value", flags)
        return bpy.data.objects.new(name, mesh)
