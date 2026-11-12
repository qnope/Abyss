"""The crown (Tier3): a tall silo on legs fed by a second belt from the
hopper, a beacon and a boom light on the rig, and the lode breaking through
in bigger crystals."""

import math

from catalog import colors
from catalog.ore_extractor.line import HOPPER, ORE
from catalog.ore_extractor.rig import AT, HEAD, PZ, STEEL
from catalog.paints import machined
from catalog.parts import Into, belts, crystals, fittings, light, place, production
from workshop import shapes, sweep

SILO = (0.42, 0.62)


def crown(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    x, y = SILO
    for k in range(4):
        a = math.pi / 4 + k * math.pi / 2
        leg = shapes.box((0.03, 0.03, 0.26), bottom=False).transform((x + 0.13 * math.cos(a), y + 0.13 * math.sin(a), PZ))
        into.add(leg, "hull", colors.METAL_DARK, atlas.solid("plain")(leg))
    cone = sweep.lathe([(0.04, 0.0), (0.05, 0.03), (0.17, 0.2)], sides=12, smooth=False)
    place(into, [(cone, "hull", machined(STEEL, 100, soot=0.4), atlas.fit("plate")(cone))],
          (x, y, PZ + 0.1))
    place(into, production.tank(atlas, 0.2, 0.72, STEEL, sides=12, ladder=False, seed=101), (x, y, PZ + 0.3))
    stripe = shapes.cylinder(0.206, 0.05, sides=12, smooth=False, bottom=False)
    place(into, [(stripe, *light(atlas, "blue"))], (x, y, PZ + 0.72))
    place(into, belts.conveyor(atlas, rng, (HOPPER[0] - 0.02, HOPPER[1] + 0.16, PZ + 0.56),
                               (x - 0.12, y - 0.1, PZ + 1.04), ORE, "blue", seed=102))
    place(into, fittings.beacon(atlas, 0.04, "blue", seed=103), (AT[0], AT[1], PZ + HEAD + 0.19))
    for a, d, size in ((2.0, 0.45, 0.55), (4.3, 0.5, 0.45), (5.6, 0.62, 0.5)):
        place(into, crystals.cluster(atlas, rng, 5, size, "blue"),
              (AT[0] + d * math.cos(a), AT[1] + d * math.sin(a), PZ))
