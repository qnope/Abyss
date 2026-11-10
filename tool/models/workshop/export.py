"""Writes the scene as a glb the game imports."""

import bpy


def export_glb(path):
    """Every object of the scene to [path]: Y up, normals and vertex colours,
    no UV (nothing is textured), no camera, light or animation."""
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(
        filepath=path, export_format="GLB", use_selection=False,
        export_yup=True, export_apply=True, export_normals=True,
        export_texcoords=False, export_tangents=False,
        export_vertex_color="ACTIVE", export_all_vertex_colors=False,
        export_materials="EXPORT", export_cameras=False, export_lights=False,
        export_extras=False, export_animations=False)
