"""The barracks' second tier, the garrison: a gate tower at the hall's left end
with its slits, banner and searchlight, a bunk module on the roof with
warm windows, a ladder, a second rack and the reef taking the plinth."""

import math

from catalog.barracks.hall import FOOT, FRONT, ROOF
from catalog.paints import machined
from catalog.parts import command as c
from catalog.parts import command_tech as t
from catalog.parts import place, props, rails, reef
from workshop import shapes

TOWER = (0.42, 0.42, 1.05)  # width, depth, height of the gate tower
LEFT = -0.62


def tier2(coll, model):
    atlas = model.atlas
    w, d, h = TOWER
    place(coll, t.tower(atlas, (w, d), h, seed=30), (LEFT, 0.04, FOOT))
    top = FOOT + h + 0.1
    for z in (0.45, 0.8):
        place(coll, c.window(atlas, 0.07, 0.16, "ribbon_red"), (LEFT, 0.04 - d / 2 + 0.02, z + FOOT))
    place(coll, c.banner(atlas, 0.2, 0.42, colour=c.CLOTH, seed=2), (LEFT, 0.04 - d / 2 + 0.02, FOOT + 0.38 - 0.1))
    place(coll, t.searchlight(atlas, seed=3), (LEFT + 0.1, 0.0, top), (0, 0, math.radians(-20)))
    place(coll, c.lamp(atlas, "red", (LEFT - 0.12, 0.1, top + 0.1), 0.04))
    _bunks(coll, atlas)
    place(coll, rails.ladder(atlas, ROOF - FOOT + 0.1), (0.3, FRONT - 0.005, FOOT), (0, 0, 0))
    place(coll, t.rack(atlas, 3, 0.45, seed=6), (-0.2, FRONT - 0.2, FOOT))
    place(coll, props.crate(atlas, (0.14, 0.12, 0.1), colour=c.ARMOR_DARK, seed=7), (0.45, FRONT - 0.2, FOOT),
          (0, 0, -0.3))
    reef.cluster(coll, model.rng, atlas, (-0.82, -0.6, 0.0), 0.7, 3)
    reef.cluster(coll, model.rng, atlas, (0.72, 0.5, 0.0), 0.55, 2)


def _bunks(coll, atlas):
    size = (0.78, 0.4, 0.3)
    at = (0.22, 0.0, ROOF)
    block = shapes.box(size, bevel=0.012, bottom=False)
    block.subdivide(0.3)
    place(coll, [(block, "hull", machined(c.ARMOR, 31, soot=0.2), t.sided(atlas, block, "plate_wide", "plate"))], at)
    for x in (-0.22, 0.0, 0.22):
        place(coll, c.window(atlas, 0.15, 0.12, "panes_amber"), (at[0] + x, -size[1] / 2 - 0.004, ROOF + 0.12))
    roof = shapes.box((size[0] + 0.08, size[1] + 0.08, 0.04), bevel=0.01, bottom=False)
    coll.add(roof.transform((at[0], 0, ROOF + size[2] - 0.01)), "hull", machined(c.ARMOR_DARK, 32, soot=0.0),
             t.sided(atlas, roof, "strap", "tread"))
    place(coll, c.lamp(atlas, "red", (at[0] + 0.3, -0.18, ROOF + size[2] + 0.06)))
