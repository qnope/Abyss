"""The solar panel's housing (Tier1): a chamfered block of inverters on the
steel deck, louvred on its flanks, gold charge gauges on the faces toward the
camera, a door toward the headquarters, a bank of capacitor drums on its
roof, cables into the deck and the reef settling at its corners."""

import math

from catalog import colors
from catalog.paints import machined
from catalog.parts import Into, hatches, light, place, plumbing, production, props, reef, sides_and_top
from workshop import shapes

PZ = 0.09  # the deck's top, above the pad
SIDE, CHAMFER, HEIGHT = 1.0, 0.2, 0.28
ROOF = PZ + HEIGHT


def housing(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    place(into, production.deck(atlas, strip="gold", seed=110))
    block = shapes.prism(shapes.chamfered_square(SIDE, CHAMFER), HEIGHT, bevel=0.025, top=0.97,
                         bottom=False).subdivide(0.25).transform((0, 0, PZ))
    into.add(block, "hull", machined(colors.HULL, 111, soot=0.4, height=0.3),
             sides_and_top(atlas, block, "plate_wide", "tread"))
    rim = shapes.prism(shapes.chamfered_square(SIDE * 0.97 + 0.02, CHAMFER), 0.04, bottom=False)
    rim.faces = [f for i, f in enumerate(rim.faces) if abs(rim.face_normal(i).z) < 0.5]
    rim.smooth = [False] * len(rim.faces)
    into.add(rim.transform((0, 0, ROOF - 0.04)), "hull", colors.WHITE, atlas.fit("hazard"))
    half = SIDE / 2
    for k in range(4):
        angle = k * math.pi / 2
        out, turn = (math.cos(angle), math.sin(angle)), (0, 0, angle + math.pi / 2)
        if k in (0, 3):  # east and south, toward the camera: gauges
            _gauges(into, atlas, (out[0] * (half + 0.003) + (0.18 if k == 3 else 0.0),
                                  out[1] * (half + 0.003), PZ + 0.13), turn, k)
        else:
            vent = shapes.box((0.5, 0.02, 0.15), bevel=0.005)
            place(into, [(vent, "hull", colors.STONE_WORN, atlas.fit("vent")(vent))],
                  (out[0] * half, out[1] * half, PZ + 0.07), turn)
    place(into, hatches.door(atlas, 0.17, 0.19, colour=colors.STONE, seed=112), (-0.25, -half - 0.005, PZ))
    _capacitors(into, atlas)
    path = [(-0.1, -half + 0.02, ROOF - 0.04), (-0.1, -half - 0.08, PZ + 0.1), (-0.14, -half - 0.2, PZ + 0.02)]
    for k, x in enumerate((0.0, 0.05)):
        place(into, plumbing.pipe(atlas, [(p[0] + x, *p[1:]) for p in path], 0.02,
                                  colors.PIPE if k else colors.HULL_DARK, 1, k, 6))
    for x, y, size in ((0.72, -0.74, 0.8), (-0.76, 0.7, 0.75), (0.76, 0.7, 0.55), (-0.76, -0.74, 0.6)):
        reef.cluster(into, rng, atlas, (x, y, 0), size, 3)


def _gauges(into, atlas, at, turn, seed):
    """A panel of five charge gauges, gold, the last one dimmed."""
    plate = shapes.box((0.42, 0.02, 0.12), bevel=0.006)
    parts = [(plate, "hull", machined(colors.HULL_DARK, 120 + seed, soot=0.0), atlas.fit("plate_wide")(plate))]
    for i in range(5):
        bar = shapes.box((0.05, 0.012, 0.06)).transform((-0.16 + i * 0.08, -0.012, 0.03))
        parts.append((bar, *light(atlas, "gold" if i < 4 else "rust")))
    place(into, parts, at, turn)


def _capacitors(into, atlas):
    """Three upright drums banded in gold on the roof, and a crate."""
    for k, (dx, dy) in enumerate(((0.0, 0.0), (0.13, 0.03), (0.05, -0.12))):
        parts = props.drum(atlas, 0.06, 0.2, colour=colors.HULL_DARK, seed=130 + k)
        ring = shapes.cylinder(0.063, 0.02, sides=10, bottom=False).transform((0, 0, 0.16))
        parts.append((ring, *light(atlas, "gold")))
        place(into, parts, (-0.36 + dx, 0.3 + dy, ROOF - 0.012))
    place(into, props.crate(atlas, (0.16, 0.12, 0.1), seed=133), (0.3, 0.3, ROOF - 0.012), (0, 0, 0.3))
