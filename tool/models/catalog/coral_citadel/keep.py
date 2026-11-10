"""The citadel's keep: a swelling polyp of grown stone bound by riveted
bands, pink slits, a railed gallery, a brain-coral dome and a crown of
thorns around the Heart, a pink crystal in a cradle (node Heart)."""

import math

from catalog import colors
from catalog.coral_citadel.stone import grown, living, stone
from catalog.decor import creatures
from catalog.paints import machined
from catalog.parts import Into, dress, light, place, reef
from workshop import shapes, sweep

BODY = [(0.5, -0.02), (0.48, 0.25), (0.41, 0.6), (0.34, 0.95), (0.32, 1.18), (0.0, 1.2)]
# The polyp's calyx opening at the top, out and back in: living coral.
CALYX = [(0.31, 1.14), (0.38, 1.28), (0.5, 1.42), (0.6, 1.53), (0.58, 1.57), (0.47, 1.49),
         (0.3, 1.41), (0.0, 1.38)]
COLLAR = (0.335, 1.08, 0.09)  # radius, bottom, height of the riveted collar
HEART = 1.5


def keep(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    seed = rng.randrange(1000)
    body = grown(sweep.lathe(BODY, sides=16), seed, 0.03, 0.14)
    into.add(body, "reef", stone(rng, seed, moss=0.5), atlas.tiled("coral", 1.0))
    for z, r in ((0.32, 0.475), (0.98, 0.365)):
        band = shapes.cylinder(r, 0.07, sides=16, top_radius=r - 0.01, smooth=False).transform((0, 0, z))
        into.add(band, "hull", machined(colors.HULL_DARK, 70, soot=0.0), atlas.fit("strap"))
    for k in range(4):
        a = math.pi / 4 + k * math.pi / 2
        for z, r in ((0.5, 0.45), (0.8, 0.385)):
            slit = shapes.box((0.06, 0.02, 0.16), bottom=False)
            place(into, [(slit, "lamp", colors.LAMP, atlas.fit("panes_pink")(slit))],
                  (r * math.cos(a), r * math.sin(a), z), (0, 0, a + math.pi / 2))
    calyx = grown(sweep.lathe(CALYX, sides=16), seed + 1, 0.02, 0.12)
    into.add(calyx, "reef", living(seed, 1.14, 1.57), atlas.tiled("coral", 1.0))
    radius, bottom, height = COLLAR
    collar = shapes.cylinder(radius, height, sides=16, bevel=0.01, smooth=False).transform((0, 0, bottom))
    into.add(collar, "hull", machined(colors.HULL_DARK, 71, soot=0.0), atlas.fit("bolt"))
    _crown(model, group, into, atlas, rng)


def _crown(model, group, into, atlas, rng):
    """Tentacles curling out of the calyx's rim, the heart in its mouth."""
    for k in range(11):
        a = 2 * math.pi * k / 11 + rng.uniform(-0.1, 0.1)
        root = (0.56 * math.cos(a), 0.56 * math.sin(a), 1.53)
        place(into, reef.thorn(atlas, rng, rng.uniform(0.26, 0.38), 0.04,
                               (math.cos(a), math.sin(a), 0.7), colors.CORAL_PINK, colors.SHELL), root)
    cradle = sweep.lathe([(0.07, 0.0), (0.12, 0.05), (0.13, 0.09), (0.1, 0.1), (0.05, 0.03), (0.0, 0.02)],
                         sides=8)
    heart = shapes.octahedron(0.13).transform((0, 0, 0.0), scale=(1, 1, 1.9))
    facets = shapes.octahedron(0.095).transform((0, 0, 0.0), (0, 0, math.pi / 4), scale=(1, 1, 2.4))
    piece = model.piece(f"{group}/Heart", (0, 0, HEART))
    place(piece, [(cradle, "hull", machined(colors.HULL_DARK, 72, soot=0.0), atlas.fit("bolt")(cradle)),
                  (heart.transform((0, 0, 0.26)), *light(atlas, "pink")),
                  (facets.transform((0, 0, 0.26)), *light(atlas, "pink"))])
    for k in range(14):  # glowing mouths of the calyx's polyps
        a = 2 * math.pi * k / 14 + 0.1
        r = 0.42 if k % 2 else 0.33
        dot = shapes.octahedron(0.022).transform((r * math.cos(a), r * math.sin(a), 1.405 + r * 0.12))
        into.add(dot, *light(atlas, "pink"))
    for k in range(3):
        a = 2 * math.pi * k / 3
        polyp = dress(creatures.anemone(rng, rng.uniform(0.35, 0.5)), atlas)
        place(into, polyp, (0.3 * math.cos(a), 0.3 * math.sin(a), 1.42), (0, 0, a))
