"""The keep's upper works: a railed gallery on brackets, the bridge's drum
ringed with cyan windows, a ribbed glass cupola, and the crown: a mast with
a yard of lamps, the beacon (node Beacon) and a dish (node Dish)."""

import math

from mathutils import Vector

from catalog import colors
from catalog.headquarters.keep import HULL, PHASE, SIDES
from catalog.paints import machined
from catalog.parts import Into, fittings, light, place, rails
from workshop import shapes, sweep

GALLERY = (1.05, HULL[3], 0.05)  # radius, bottom, thickness
DRUM = (0.68, 0.64, 1.2, 1.62)  # radius at foot and top, from z to z
DOME = [(0.66, 1.67), (0.65, 1.8), (0.6, 1.94), (0.5, 2.06), (0.36, 2.16), (0.2, 2.23), (0.12, 2.25)]
MAST = (2.32, 0.7)  # foot, height


def bridge(model, group):
    atlas, into = model.atlas, Into(model, group)
    radius, bottom, thick = GALLERY
    deck = shapes.prism(shapes.polygon(SIDES, radius, PHASE), thick, bevel=0.012,
                        bottom=True).transform((0, 0, bottom))
    top = atlas.fit("tread")(deck)
    side = atlas.fit("strap")(deck)
    into.add(deck, "hull", machined(colors.HULL, 30, soot=0.0),
             [top[i] if deck.face_normal(i).z > 0.9 else side[i] for i in range(len(deck.faces))])
    for k in range(SIDES):
        a = PHASE + 2 * math.pi * k / SIDES
        gusset = shapes.prism([(0, 0), (0.13, 0), (0, 0.12)], 0.03).transform((0, 0, -0.015),
                                                                              (math.pi / 2, 0, 0))
        place(into, [(gusset, "hull", colors.METAL_DARK, None)],
              (0.9 * math.cos(a), 0.9 * math.sin(a), bottom - 0.12), (0, 0, a))
    edge = [((radius - 0.03) * math.cos(a), (radius - 0.03) * math.sin(a), bottom + thick)
            for a in (PHASE + math.pi * k / SIDES for k in range(2 * SIDES))]
    place(into, rails.railing(atlas, edge, 0.13))
    _drum(into, atlas)
    _cupola(into, atlas)
    _crown(model, group, into, atlas)


def _drum(into, atlas):
    low, high, bottom, top = DRUM
    drum = shapes.cylinder(low, top - bottom, sides=16, top_radius=high, smooth=False,
                           bottom=False).transform((0, 0, bottom)).subdivide(0.2)
    into.add(drum, "hull", machined(colors.HULL, 31, soot=0.0), atlas.fit("plate"))
    for k in range(16):
        a = 2 * math.pi * (k + 0.5) / 16
        pane = shapes.box((0.19, 0.02, 0.13), bottom=False)
        pane.faces = [f for i, f in enumerate(pane.faces) if pane.face_normal(i).y < -0.5]
        pane.smooth = [False] * len(pane.faces)
        mapped = atlas.fit("bridge")(pane)
        place(into, [(pane, "lamp", colors.LAMP, mapped)],
              (math.cos(a) * (low - 0.012), math.sin(a) * (low - 0.012), bottom + 0.16),
              (-0.06, 0, a + math.pi / 2))
    cornice = shapes.cylinder(high + 0.06, 0.06, sides=16, top_radius=high + 0.03, bevel=0.01,
                              smooth=False).transform((0, 0, top))
    into.add(cornice, "hull", machined(colors.TRIM, 32, soot=0.0), atlas.fit("bolt"))
    strip = shapes.cylinder(high + 0.062, 0.016, sides=16, smooth=False, bottom=False)
    strip.faces = [f for i, f in enumerate(strip.faces) if abs(strip.face_normal(i).z) < 0.5]
    strip.smooth = [False] * len(strip.faces)
    into.add(strip.transform((0, 0, top - 0.012)), *light(atlas, "cyan"))


def _cupola(into, atlas):
    glass = sweep.lathe(DOME, sides=12, phase=math.pi / 12, smooth=False)
    into.add(glass, "glass", colors.GLASS, atlas.fit("glass"))
    for k in range(12):
        a = 2 * math.pi * k / 12
        out = Vector((math.cos(a), math.sin(a), 0))
        path = [out * (r + 0.012) + Vector((0, 0, z)) for r, z in DOME]
        rib = sweep.tube(path, [0.016] * len(path), sides=4, cap=False)
        into.add(rib, "hull", colors.LIMESTONE, atlas.solid("plain"))
    collar = shapes.cylinder(0.16, 0.08, sides=10, top_radius=0.12, bevel=0.01,
                             bottom=False).transform((0, 0, 2.24))
    into.add(collar, "hull", machined(colors.METAL_DARK, 33, soot=0.0), atlas.fit("bolt"))


def _crown(model, group, into, atlas):
    foot, height = MAST
    place(into, fittings.mast(atlas, height, 0.035), (0, 0, foot))
    yard = shapes.box((0.42, 0.025, 0.025), bevel=0.005).transform((0, 0, foot + height * 0.62))
    into.add(yard, "hull", colors.METAL_DARK, None)
    for x in (-0.21, 0.21):
        lamp = shapes.octahedron(0.03).transform((x, 0, foot + height * 0.62 + 0.03))
        into.add(lamp, *light(atlas, "amber"))
    place(model.piece(f"{group}/Beacon", (0, 0, foot + height)), fittings.beacon(atlas, 0.06))
    arm = sweep.tube([(0.3, 0.48, 1.66), (0.4, 0.62, 1.84)], [0.022, 0.016], sides=5, cap=False)
    into.add(arm, "hull", colors.HULL_DARK, None)
    dish = model.piece(f"{group}/Dish", (0.4, 0.62, 1.86))
    place(dish, fittings.dish(atlas, 0.17, 0.08), rotation=(0.55, 0, 0.6))
