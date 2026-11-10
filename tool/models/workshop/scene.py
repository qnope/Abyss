"""The Blender scene a model is built in."""

import bpy


def fresh_scene():
    """An empty scene, as Blender starts with no startup file."""
    bpy.ops.wm.read_factory_settings(use_empty=True)
    return bpy.context.scene


def link(obj, parent=None):
    bpy.context.scene.collection.objects.link(obj)
    obj.parent = parent
    return obj


def empty(name, parent=None, location=(0, 0, 0)):
    obj = bpy.data.objects.new(name, None)
    obj.location = location
    return link(obj, parent)
