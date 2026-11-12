"""A declared Rig (rig.py) as a Blender armature, skinned meshes and actions,
which the glTF export writes as a skin and animations."""

import math

import bpy
from mathutils import Euler, Matrix, Vector

from workshop.scene import link

# Each action is pushed on an NLA track of its name, which the export writes
# as one animation. A loop gets this suffix, which Godot's importer reads as
# "play it again" (and removes from the name).
LOOP_SUFFIX = "_loop"


def animation_name(action):
    return action.name + (LOOP_SUFFIX if action.loop else "")


def create(rig):
    """The armature object of [rig], the node Rig at the origin, its bones
    where the rig puts them."""
    data = bpy.data.armatures.new("Rig")
    obj = link(bpy.data.objects.new("Rig", data))
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode="EDIT")
    for bone in rig.bones:
        edit = data.edit_bones.new(bone.name)
        edit.head, edit.tail = Vector(bone.head), Vector(bone.tail)
        edit.parent = data.edit_bones[bone.parent] if bone.parent else None
    bpy.ops.object.mode_set(mode="OBJECT")
    return obj


def skin(obj, weights, armature):
    """Binds the mesh [obj] to [armature]: one vertex group per bone, filled
    from [weights], the {bone: weight} of each vertex; the armature is its
    modifier and its parent."""
    groups = {bone.name: obj.vertex_groups.new(name=bone.name) for bone in armature.data.bones}
    for index, vertex in enumerate(weights):
        for bone, weight in vertex.items():
            groups[bone].add([index], weight, "REPLACE")
    obj.modifiers.new("Armature", "ARMATURE").object = armature


def animate(armature, rig):
    """The actions of [rig] keyed on the pose bones of [armature], each on an
    NLA track."""
    armature.animation_data_create()
    for action in rig.actions:
        blender_action = bpy.data.actions.new(animation_name(action))
        armature.animation_data.action = blender_action
        for bone, keys in action.tracks.items():
            pose = armature.pose.bones[bone]
            pose.rotation_mode = "QUATERNION"
            rest = pose.bone.matrix_local.to_3x3()
            for key in keys:
                pose.rotation_quaternion = _local(rest, Euler([math.radians(a) for a in
                                                               key.rotation]).to_matrix()).to_quaternion()
                pose.location = rest.inverted() @ Vector(key.location)
                pose.keyframe_insert("rotation_quaternion", frame=key.frame)
                pose.keyframe_insert("location", frame=key.frame)
            pose.rotation_quaternion = (1, 0, 0, 0)
            pose.location = (0, 0, 0)
        armature.animation_data.action = None
        track = armature.animation_data.nla_tracks.new()
        track.name = blender_action.name
        track.strips.new(blender_action.name, 0, blender_action)


def _local(rest, turn):
    """The rotation [turn], about the model's axes, as the bone with the rest
    orientation [rest] turns about its own."""
    return Matrix(rest).inverted() @ turn @ Matrix(rest)
