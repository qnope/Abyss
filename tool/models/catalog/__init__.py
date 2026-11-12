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
    abyss_admiral,
    algae_farm,
    barracks,
    base_island,
    base_rampart,
    coral_citadel,
    coral_mine,
    descent_module,
    dome_breaker,
    guardian,
    harpoonist,
    headquarters,
    laboratory,
    map_lair_easy,
    map_lair_medium,
    map_resource_algae,
    map_resource_coral,
    map_resource_ore,
    map_ruins,
    map_treasure,
    map_wreck,
    material_swatches,
    ore_extractor,
    pressure_capsule,
    probe_fish,
    saboteur,
    scout,
    solar_panel,
    volcanic_kernel,
    armoured,
    colossus,
    hunter,
    kraken,
    leviathan,
    monster_generic,
    swarm,
)

MODELS = {script.NAME: script for script in (
    abyss_admiral,
    algae_farm,
    barracks,
    base_island,
    base_rampart,
    coral_citadel,
    coral_mine,
    descent_module,
    dome_breaker,
    guardian,
    harpoonist,
    headquarters,
    laboratory,
    map_lair_easy,
    map_lair_medium,
    map_resource_algae,
    map_resource_coral,
    map_resource_ore,
    map_ruins,
    map_treasure,
    map_wreck,
    material_swatches,
    ore_extractor,
    pressure_capsule,
    probe_fish,
    saboteur,
    scout,
    solar_panel,
    volcanic_kernel,
    armoured,
    colossus,
    hunter,
    kraken,
    leviathan,
    monster_generic,
    swarm,
)}
