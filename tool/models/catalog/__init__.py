"""Every model of the game, by name: one script each, which declares

    NAME, SEED        the glb's name, and the seed of everything it draws
    MATERIALS         the materials it may use (from palette)
    FAMILY            building, unit, monster, map or decor: the caps its BUDGET
                      stays within (families.py)
    BUDGET            triangles, materials, texture size, bones and keyframes,
                      enforced on build
    PORTRAIT          optional, True when portraits.sh renders the model's picture
                      for the interface (godot/assets/portraits/<name>.png)
    OCCLUSION         how its ambient occlusion is baked
    NODES             the node paths the game relies on
    build(model)      fills the workshop's Model
"""

from catalog import (
    algae_farm,
    base_island,
    base_rampart,
    coral_citadel,
    coral_mine,
    headquarters,
    material_swatches,
    ore_extractor,
    probe_fish,
    solar_panel,
    laboratory,
)

MODELS = {script.NAME: script for script in (
    algae_farm,
    base_island,
    base_rampart,
    coral_citadel,
    coral_mine,
    headquarters,
    material_swatches,
    ore_extractor,
    probe_fish,
    solar_panel,
    laboratory,
)}
