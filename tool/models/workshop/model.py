"""What a model script fills: static parts, joined per material under a
group node, and pieces, each a node of its own that the game can show, hide
or tint."""

import random

import bpy

from workshop import armature
from workshop.builder import MeshBuilder
from workshop.occlusion import Occlusion
from workshop.rig import Rig
from workshop.scene import empty, link


class Model:
    """A model under construction. [rng] is seeded by [seed]: drawing from it
    in the same order gives the same model. With an [atlas], its faces may
    be mapped into it (add's uv), and the others take its white tile."""

    def __init__(self, name, seed, materials, occlusion=Occlusion(), atlas=None):
        self.name, self.seed, self.atlas = name, seed, atlas
        self.rng = random.Random(seed)
        self.materials = {material.name: material for material in materials}
        self.occlusion = occlusion
        self._groups = {}
        self._pieces = {}
        self.rig = Rig()

    def add(self, group, geometry, material, paint, uv=None, bone=None):
        """Static [geometry] of the node [group] ('Island', 'Tier1'), joined
        with the rest of its [material] there: one draw call per material.
        [uv] maps it into the atlas (Atlas.fit, tiled, solid...). [bone] skins
        it to the model's rig (see workshop.skin)."""
        if material not in self.materials:
            raise KeyError(f"{self.name} has no material {material}")
        builders = self._groups.setdefault(group, {})
        builders.setdefault(material, self._builder()).add(geometry, material, paint, uv, bone)

    def piece(self, path, location=(0, 0, 0)):
        """The builder of the node at [path] ('Pads/Headquarters'), its origin
        at [location]: geometry added to it is in its own space."""
        if path not in self._pieces:
            self._pieces[path] = (self._builder(), tuple(location))
        return self._pieces[path][0]

    def _builder(self):
        return MeshBuilder(self.atlas.blank if self.atlas else None)

    @property
    def triangles(self):
        builders = [b for group in self._groups.values() for b in group.values()]
        return sum(b.triangles for b in builders + [p[0] for p in self._pieces.values()])

    def emit(self):
        """Creates the Blender objects, bakes their occlusion and gives them."""
        used = [name for name in self.materials if self._uses(name)]
        library = {name: self.materials[name].create() for name in used}
        nodes, objects, skinned = {}, [], []
        arm = armature.create(self.rig) if self.rig.bones else None
        for group, builders in self._groups.items():
            parent = arm or self._node(group, nodes)
            leaf = group.rsplit("/", 1)[-1]
            for material in used:
                if material in builders:
                    obj = builders[material].to_object(f"{leaf}_{material}", library)
                    objects.append(link(obj, parent))
                    skinned.append((obj, builders[material]))
        for path, (builder, location) in self._pieces.items():
            parent, _, leaf = path.rpartition("/")
            obj = builder.to_object(leaf, library)
            obj.location = location
            objects.append(link(obj, arm or (self._node(parent, nodes) if parent else None)))
            skinned.append((obj, builder))
        self._skin(skinned, arm)
        bpy.context.view_layer.update()
        self.occlusion.bake(objects)
        return objects

    def _skin(self, skinned, arm):
        """Binds the objects to the armature [arm] of the rig and keys its
        actions; every vertex of a rigged model follows a bone, and none of
        another does. A rigged model's meshes are the children of the
        armature, the node Rig: its groups only name them."""
        if arm is None:
            if any(any(builder.weights) for _, builder in skinned):
                raise ValueError(f"{self.name} skins parts to bones, but declares none")
            return
        if any(None in builder.weights for _, builder in skinned):
            raise ValueError(f"{self.name} has a rig: every part needs a bone")
        for obj, builder in skinned:
            armature.skin(obj, builder.weights, arm)
        armature.animate(arm, self.rig)

    def _uses(self, material):
        return any(material in builders for builders in self._groups.values()) or any(
            material in builder.materials for builder, _ in self._pieces.values())

    def _node(self, path, nodes):
        if path not in nodes:
            parent, _, leaf = path.rpartition("/")
            nodes[path] = empty(leaf, self._node(parent, nodes) if parent else None)
        return nodes[path]
