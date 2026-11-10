"""Every model of the game, by name: one script each, which declares

    NAME, SEED        the glb's name, and the seed of everything it draws
    MATERIALS         the materials it may use (from palette)
    BUDGET            triangles, materials and texture size, enforced on build
    OCCLUSION         how its ambient occlusion is baked
    NODES             the node paths the game relies on
    build(model)      fills the workshop's Model
"""

from catalog import base_island, base_rampart, material_swatches

MODELS = {script.NAME: script for script in (base_island, base_rampart, material_swatches)}
