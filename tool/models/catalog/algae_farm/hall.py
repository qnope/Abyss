"""The glasshouse: a barrel vault of lit green panes on the steel deck, its
door at the west end, a lamp post and crates beside it, a pipe from the
tank, and (Tier2) a ridge lantern, a second, smaller vault riding its top."""

import math

from catalog import colors
from catalog.parts import Into, fittings, glasshouse, hatches, place, plumbing, production, props, reef
from workshop import shapes

PZ = 0.09  # the deck's top, above the pad
AT = (-0.02, 0.4, PZ)  # the glasshouse's axis
LENGTH, RADIUS, HEIGHT = 1.3, 0.33, 0.38
TANK = (0.5, -0.46)


def hall(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    place(into, production.deck(atlas, strip="green", seed=1))
    panes, ends = glasshouse.vault(atlas, LENGTH, RADIUS, HEIGHT, seed=2)
    place(into, panes + ends, AT)
    west = AT[0] - LENGTH / 2
    place(into, hatches.door(atlas, 0.17, 0.2, colour=colors.HULL_DARK, seed=3),
          (west - 0.005, AT[1], PZ), (0, 0, -math.pi / 2))
    place(into, fittings.beacon(atlas, 0.035, "green", seed=4), (west - 0.1, AT[1] + 0.3, PZ))
    place(into, fittings.beacon(atlas, 0.035, "green", seed=5), (AT[0] + LENGTH / 2 + 0.08, 0.02, PZ))
    place(into, props.crate(atlas, (0.12, 0.1, 0.09), colors.PIPE, seed=6),
          (west - 0.1, AT[1] - 0.2, PZ), (0, 0, 0.3))
    place(into, props.drum(atlas, 0.05, 0.14, colors.CORAL_ORANGE, seed=7), (west - 0.12, AT[1] - 0.33, PZ))
    pipe = [(TANK[0] - 0.08, TANK[1] + 0.17, PZ + 0.3), (TANK[0] - 0.1, 0.0, PZ + 0.32),
            (TANK[0] - 0.1, 0.1, PZ + 0.2)]
    place(into, plumbing.pipe(atlas, pipe, 0.032, colors.PIPE, flanges=1, seed=8))
    for x, y, size in ((0.76, 0.72, 0.8), (-0.76, -0.76, 0.85), (0.78, -0.76, 0.7)):
        reef.cluster(into, rng, atlas, (x, y, 0), size, 3)


def lantern(model, group):
    """The ridge lantern, its base buried in the roof it stands on."""
    atlas, into = model.atlas, Into(model, group)
    panes, ends = glasshouse.vault(atlas, 0.9, 0.16, 0.17, facets=6, sections=4, seed=9)
    place(into, panes + ends, (AT[0], AT[1], PZ + 0.335))
    for x in (-0.3, 0.3):
        vent = shapes.box((0.12, 0.1, 0.05), bevel=0.008, bottom=False)
        place(into, [(vent, "hull", colors.HULL_DARK, atlas.fit("vent")(vent))],
              (AT[0] + x, AT[1], PZ + HEIGHT + 0.14))
