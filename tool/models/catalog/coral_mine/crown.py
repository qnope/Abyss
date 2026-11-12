"""The crown (Tier3): the headframe's mast rising from its landing to a
second sheave (the node CrownWheel) under a pink beacon, a rail round the
landing, floodlamps, and the lode breaking through round the collar in
crystals."""

import math

from catalog import colors
from catalog.coral_mine.shaft import AT, FRAME, PZ, STEEL
from catalog.parts import Into, crystals, fittings, lattice, light, place, production, rails
from workshop import shapes


def crown(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    x, y = AT
    base, top, height = FRAME
    z = PZ + height + 0.04
    place(into, lattice.tower(atlas, top * 0.9, 0.08, 0.7, 3, 0.011, STEEL, seed=60), (x, y, z))
    place(into, lattice.cap(atlas, 0.2, 0.035, colors.HULL, seed=61), (x, y, z + 0.7))
    wheel = model.piece(f"{group}/CrownWheel", (x, y, z + 0.82))
    place(wheel, production.wheel(atlas, 0.075, 6, 0.012, colors.HULL, seed=62))
    for side in (-1, 1):
        cheek = shapes.box((0.02, 0.025, 0.12), bottom=False)
        place(into, [(cheek, "hull", colors.HULL_DARK, atlas.solid("plain")(cheek))],
              (x + side * 0.07, y, z + 0.735))
    place(into, fittings.beacon(atlas, 0.04, "pink", seed=63), (x, y, z + 0.9))
    half = top + 0.03
    edge = [(x + sx * half, y + sy * half, PZ + height + 0.08) for sx, sy in
            ((1, 1), (-1, 1), (-1, -1), (1, -1))]
    place(into, rails.railing(atlas, edge, 0.1))
    for a in (0.8, 2.4, 3.9, 5.4):
        lamp = shapes.cylinder(0.025, 0.04, sides=6, top_radius=0.04).transform((0, 0, 0))
        place(into, [(lamp, "hull", colors.METAL_DARK, None),
                     (shapes.octahedron(0.026).transform((0, 0, 0.05)), *light(atlas, "pink"))],
              (x + 0.12 * math.cos(a), y + 0.12 * math.sin(a), z + 0.68), (0, 0, a))
    for a, d, size in ((0.5, 0.4, 0.46), (2.3, 0.42, 0.38), (4.0, 0.4, 0.5), (5.3, 0.41, 0.34)):
        place(into, crystals.cluster(atlas, rng, 5, size, "pink"),
              (x + d * math.cos(a), y + d * math.sin(a), PZ))
