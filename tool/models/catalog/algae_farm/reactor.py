"""The nutrient tank at the front corner (Tier1) and, on its lid, the
bioreactor (Tier3): a tower of glowing broth in a cage of rings, bubbles
rising in it, a green beacon on its dome."""

import math

from catalog import colors
from catalog.algae_farm.hall import PZ, TANK
from catalog.paints import machined
from catalog.parts import Into, fittings, glasshouse, place, production
from workshop import shapes, sweep

TANK_RADIUS, TANK_HEIGHT = 0.21, 0.46
STEEL = colors.HULL


def tank(model, group):
    atlas, into = model.atlas, Into(model, group)
    place(into, production.tank(atlas, TANK_RADIUS, TANK_HEIGHT, STEEL, seed=20), (*TANK, PZ))
    place(into, glasshouse.pane_strip(atlas, (0.05, 0.02, 0.2), "panes_cyan"),
          (TANK[0] + 0.12, TANK[1] - TANK_RADIUS * 0.93, PZ + 0.12), (0, 0, 0.5))


def column(model, group):
    """The reactor stands on the lid; its foot is a flange of the tank's."""
    atlas, into = model.atlas, Into(model, group)
    x, y, z = TANK[0], TANK[1], PZ + TANK_HEIGHT + 0.07
    flange = shapes.cylinder(0.19, 0.05, sides=14, bevel=0.01, smooth=False, bottom=False)
    place(into, [(flange, "hull", machined(colors.HULL_DARK, 21, soot=0.0), atlas.fit("bolt")(flange))],
          (x, y, z - 0.01))
    glass = shapes.cylinder(0.16, 0.7, sides=12, top_radius=0.14, smooth=False, bottom=False)
    place(into, [(glass, "lamp", colors.LAMP, atlas.fit("reactor")(glass))], (x, y, z + 0.04))
    for k, h in enumerate((0.04, 0.24, 0.44, 0.66)):
        ring = shapes.cylinder(0.172 - 0.012 * h, 0.04, sides=12, bevel=0.006, smooth=False)
        place(into, [(ring, "hull", machined(colors.TRIM, 22 + k, soot=0.0), atlas.fit("strap")(ring))],
              (x, y, z + 0.04 + h))
    for k in range(6):
        a = math.pi / 6 + 2 * math.pi * k / 6
        post = sweep.tube([(0.175 * math.cos(a), 0.175 * math.sin(a), 0.05),
                           (0.145 * math.cos(a), 0.145 * math.sin(a), 0.72)], [0.011, 0.009],
                          sides=4, cap=False)
        place(into, [(post, "hull", colors.HULL_DARK, None)], (x, y, z))
    cap = sweep.lathe([(0.15, 0.74), (0.14, 0.78), (0.1, 0.83), (0.04, 0.86), (0.0, 0.87)], sides=12,
                      smooth=False)
    place(into, [(cap, "hull", machined(colors.HULL_DARK, 26, soot=0.0), atlas.fit("bolt")(cap))],
          (x, y, z))
    place(into, fittings.beacon(atlas, 0.04, "green", seed=27), (x, y, z + 0.86))
