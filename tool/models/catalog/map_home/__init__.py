"""The home: the player's own base on the map, in the language of the
headquarters (3 cells) shrunk to one: an octagonal plinth of blue-grey steel,
a drum ringed with a band of cyan windows, a pale ribbed cupola, an airlock
toward the camera lit amber and a mast carrying a cyan beacon. The only cyan
crown of the map (0.7 high, 0.9 wide): it reads as the colony's own, against the
dark armour of the rival outposts.

Not tintable. Front (the airlock) toward -y."""

import math

from mathutils import Vector

from catalog import colors, mapkit
from catalog.paints import machined
from catalog.parts import fittings, place
from catalog.textures import map as tiles
from workshop import shapes, sweep

NAME = "map_home"
SEED = 7901
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("plate", "bolt", "cyan", "amber", "ribbon_cyan", "weathered")
BUDGET = mapkit.budget(2_600)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY]
PLINTH, DRUM = 0.07, 0.2
DOME = [(0.3, 0.0), (0.29, 0.07), (0.25, 0.14), (0.18, 0.2), (0.1, 0.24), (0.05, 0.255)]


def build(model):
    atlas, into = model.atlas, mapkit.body(model)
    plinth = shapes.cylinder(0.46, PLINTH, sides=8, top_radius=0.43, bevel=0.012, smooth=False, bottom=False)
    into.add(plinth, "hull", machined(colors.HULL_DARK, 1, soot=0.3), atlas.fit("plate")(plinth))
    drum = shapes.cylinder(0.33, DRUM, sides=8, top_radius=0.3, smooth=False, bottom=False)
    drum.transform((0, 0, PLINTH - 0.01)).subdivide(0.2)
    into.add(drum, "hull", machined(colors.HULL, 2, soot=0.25), atlas.fit("plate")(drum))
    _windows(into, atlas)
    top = PLINTH + DRUM
    cornice = shapes.cylinder(0.33, 0.04, sides=8, bevel=0.008, smooth=False).transform((0, 0, top - 0.02))
    into.add(cornice, "hull", machined(colors.METAL_DARK, 3, soot=0.0), atlas.fit("bolt")(cornice))
    _cupola(into, atlas, top + 0.01)
    _airlock(into, atlas)
    place(into, fittings.mast(atlas, 0.26, 0.022, seed=4), (0.12, 0.12, top + 0.2))
    place(into, fittings.beacon(atlas, 0.04), (0.12, 0.12, top + 0.46))


def _windows(into, atlas):
    for k in range(8):
        a = math.pi / 8 + 2 * math.pi * k / 8
        pane = shapes.box((0.19, 0.02, 0.09), bottom=False)
        mapped = atlas.fit("ribbon_cyan")(pane)
        place(into, [(pane, "lamp", colors.LAMP, mapped)],
              (0.3 * math.cos(a), 0.3 * math.sin(a), PLINTH + 0.07), (0, 0, a + math.pi / 2))


def _cupola(into, atlas, z):
    glass = sweep.lathe(DOME, sides=12, phase=math.pi / 12, smooth=False).transform((0, 0, z))
    into.add(glass, "hull", machined(colors.LIMESTONE, 6, soot=0.1), atlas.fit("plate")(glass))
    for k in range(6):
        a = 2 * math.pi * k / 6
        out = Vector((math.cos(a), math.sin(a), 0))
        rib = sweep.tube([out * (r + 0.01) + Vector((0, 0, z + h)) for r, h in DOME], [0.012] * len(DOME),
                         sides=4, cap=False)
        into.add(rib, "hull", colors.METAL_DARK, atlas.solid("plain")(rib))


def _airlock(into, atlas):
    lock = shapes.box((0.22, 0.14, 0.15), bevel=0.012, bottom=False).transform((0, -0.37, PLINTH))
    into.add(lock, "hull", machined(colors.HULL, 5, soot=0.2), atlas.fit("plate")(lock))
    door = shapes.box((0.1, 0.02, 0.09), bottom=False).transform((0, -0.445, PLINTH + 0.01))
    into.add(door, "lamp", colors.LAMP, atlas.solid("amber")(door))
