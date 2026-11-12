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

from catalog import (base_island, base_rampart, coral_citadel, headquarters, material_swatches,
                     probe_fish, solar_panel)

MODELS = {script.NAME: script for script in (base_island, base_rampart, headquarters,
                                             solar_panel, coral_citadel, material_swatches,
                                             probe_fish)}
