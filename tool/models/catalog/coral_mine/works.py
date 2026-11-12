"""The works (Tier2): an ore bin on legs whose chute fills the cart, a
crusher with its geared flank and its stack, a belt carrying coral from the
crusher across the yard to the bin, a second cart waiting on the rails."""

from catalog import colors
from catalog.coral_mine.shaft import AT, PZ, STEEL
from catalog.paints import machined
from catalog.parts import Into, belts, light, place, plumbing, production
from workshop import shapes

BIN = (0.52, 0.45)
CRUSHER = (0.36, -0.52)


def works(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    _bin(into, atlas)
    _crusher(into, atlas)
    top = (CRUSHER[0] + 0.1, CRUSHER[1] + 0.12, PZ + 0.3)
    place(into, belts.conveyor(atlas, rng, top, (BIN[0] - 0.02, BIN[1] - 0.12, PZ + 0.52),
                               colors.CORAL_PINK, "pink", seed=50))
    place(into, belts.chunks(atlas, rng, 8, (0.1, 0.1), colors.BRAIN_ROSE, "pink", 0.05),
          (BIN[0] + 0.2, BIN[1] + 0.2, PZ))


def _bin(into, atlas):
    place(into, production.hopper(atlas, 0.32, 0.3, 0.2, STEEL, colors.CORAL_PINK, seed=52), (*BIN, PZ))
    chute = shapes.box((0.1, 0.3, 0.05), bevel=0.006)
    chute.transform(rotation=(0.45, 0, 0)).transform((BIN[0], BIN[1] - 0.15, PZ + 0.32))
    into.add(chute, "hull", colors.HULL_DARK, atlas.fit("strap")(chute))


def _crusher(into, atlas):
    x, y = CRUSHER
    body = shapes.box((0.36, 0.26, 0.24), bevel=0.014, bottom=False)
    place(into, [(body, "hull", machined(colors.HULL_DARK, 54, soot=0.3), atlas.fit("plate_wide")(body))],
          (x, y, PZ))
    for k, dx in enumerate((-0.08, 0.1)):
        place(into, production.wheel(atlas, 0.075 - 0.01 * k, 8, 0.016, colors.PIPE, seed=55 + k),
              (x + dx, y - 0.14, PZ + 0.12))
    stack = shapes.cylinder(0.04, 0.2, sides=8, top_radius=0.03, bottom=False)
    place(into, [(stack, "hull", machined(colors.METAL_DARK, 57), atlas.tiled("weathered", 0.4)(stack)),
                 (shapes.octahedron(0.025).transform((0, 0, 0.22)), *light(atlas, "pink"))],
          (x - 0.12, y + 0.05, PZ + 0.24))
    place(into, plumbing.pipe(atlas, [(x - 0.18, y, PZ + 0.1), (x - 0.3, y - 0.05, PZ + 0.1),
                                      (x - 0.3, y - 0.05, PZ + 0.02)], 0.025, colors.PIPE, 1, 58, 6))
