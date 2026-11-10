"""What a model script fills: static parts, joined per material under a
group node, and pieces, each a node of its own that the game can show, hide
or tint."""

import random

import bpy

from workshop.builder import MeshBuilder
from workshop.occlusion import Occlusion
from workshop.scene import empty, link


class Model:
    """A model under construction. [rng] is seeded by [seed]: drawing from it
    in the same order gives the same model."""

    def __init__(self, name, seed, materials, occlusion=Occlusion()):
        self.name, self.seed = name, seed
        self.rng = random.Random(seed)
        self.materials = {material.name: material for material in materials}
        self.occlusion = occlusion
        self._groups = {}
        self._pieces = {}

    def add(self, group, geometry, material, paint):
        """Static [geometry] of the node [group] ('Island', 'Tier1'), joined
        with the rest of its [material] there: one draw call per material."""
        if material not in self.materials:
            raise KeyError(f"{self.name} has no material {material}")
        builders = self._groups.setdefault(group, {})
        builders.setdefault(material, MeshBuilder()).add(geometry, material, paint)

    def piece(self, path, location=(0, 0, 0)):
        """The builder of the node at [path] ('Pads/Headquarters'), its origin
        at [location]: geometry added to it is in its own space."""
        if path not in self._pieces:
            self._pieces[path] = (MeshBuilder(), tuple(location))
        return self._pieces[path][0]

    @property
    def triangles(self):
        builders = [b for group in self._groups.values() for b in group.values()]
        return sum(b.triangles for b in builders + [p[0] for p in self._pieces.values()])

    def emit(self):
        """Creates the Blender objects, bakes their occlusion and gives them."""
        used = [name for name in self.materials if self._uses(name)]
        library = {name: self.materials[name].create() for name in used}
        nodes, objects = {}, []
        for group, builders in self._groups.items():
            parent = self._node(group, nodes)
            leaf = group.rsplit("/", 1)[-1]
            for material in used:
                if material in builders:
                    obj = builders[material].to_object(f"{leaf}_{material}", library)
                    objects.append(link(obj, parent))
        for path, (builder, location) in self._pieces.items():
            parent, _, leaf = path.rpartition("/")
            obj = builder.to_object(leaf, library)
            obj.location = location
            objects.append(link(obj, self._node(parent, nodes) if parent else None))
        bpy.context.view_layer.update()
        self.occlusion.bake(objects)
        return objects

    def _uses(self, material):
        return any(material in builders for builders in self._groups.values()) or any(
            material in builder.materials for builder, _ in self._pieces.values())

    def _node(self, path, nodes):
        if path not in nodes:
            parent, _, leaf = path.rpartition("/")
            nodes[path] = empty(leaf, self._node(parent, nodes) if parent else None)
        return nodes[path]
