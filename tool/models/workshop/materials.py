"""Materials that survive the glTF export: factors only, no Blender texture
node. The albedo comes from the vertex colour attribute COL, which the
build multiplies by the baked ambient occlusion, and, for a textured
material, by the model's atlas, which the build links in the glb."""

from dataclasses import dataclass

import bpy

from workshop.colors import linear

COLOR_ATTRIBUTE = "Col"


@dataclass(frozen=True)
class Material:
    """A material by its glTF factors. [emission] is an sRGB '#rrggbb' or
    None, [strength] its multiplier (exported as KHR_materials_emissive_strength
    above 1). A [double_sided] one is drawn from behind too: thin leaves.
    A [textured] one multiplies its colours by the model's atlas, and takes
    its emission from it when it glows: one lamp material, many lights. A
    [translucent] one (murk, mist) is drawn blended, its alpha the fourth
    channel of the corners' colours (a paint may give (r, g, b, a))."""

    name: str
    roughness: float
    metallic: float = 0.0
    emission: str | None = None
    strength: float = 1.0
    double_sided: bool = False
    textured: bool = False
    translucent: bool = False

    def create(self):
        material = bpy.data.materials.new(self.name)
        material.use_backface_culling = not self.double_sided
        nodes = material.node_tree.nodes
        shader = nodes["Principled BSDF"]
        colors = nodes.new("ShaderNodeVertexColor")
        colors.layer_name = COLOR_ATTRIBUTE
        material.node_tree.links.new(colors.outputs["Color"], shader.inputs["Base Color"])
        shader.inputs["Roughness"].default_value = self.roughness
        shader.inputs["Metallic"].default_value = self.metallic
        if self.translucent:
            material.use_backface_culling = False
            material.surface_render_method = "BLENDED"
            material.node_tree.links.new(colors.outputs["Alpha"], shader.inputs["Alpha"])
        if self.emission:
            shader.inputs["Emission Color"].default_value = (*linear(self.emission), 1)
            shader.inputs["Emission Strength"].default_value = self.strength
        return material
