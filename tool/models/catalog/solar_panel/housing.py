"""The solar panel's housing: a chamfered block of inverters, louvred on
its flanks, gold charge gauges on its faces, a bank of capacitor drums,
cables into the deck, and the reef settling on its corners."""

import math

from catalog import colors
from catalog.paints import machined
from catalog.parts import Into, hatches, light, place, plumbing, props, reef, sides_and_top
from workshop import shapes

SIDE, CHAMFER, HEIGHT = 1.24, 0.24, 0.3


def housing(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    outline = shapes.chamfered_square(SIDE, CHAMFER)
    block = shapes.prism(outline, HEIGHT, bevel=0.025, top=0.96, bottom=False).subdivide(0.25)
    into.add(block, "hull", machined(colors.HULL, 1, soot=0.45, height=0.3),
             sides_and_top(atlas, block, "plate_wide", "tread"))
    rim = shapes.prism(shapes.chamfered_square(SIDE * 0.96 + 0.02, CHAMFER), 0.04,
                       bottom=False).transform((0, 0, HEIGHT - 0.04))
    rim.faces = [f for i, f in enumerate(rim.faces) if abs(rim.face_normal(i).z) < 0.5]
    rim.smooth = [False] * len(rim.faces)
    into.add(rim, "hull", colors.WHITE, atlas.fit("hazard"))
    half = SIDE / 2
    for k in range(4):
        angle = k * math.pi / 2
        turn = (0, 0, angle + math.pi / 2)
        out = (math.cos(angle), math.sin(angle))
        if k in (0, 3):  # east and south, toward the camera: gauges and a door
            shift = 0.22 if k == 3 else 0.0
            at = (out[0] * (half + 0.003) + shift, out[1] * (half + 0.003))
            _gauges(into, atlas, at, turn, k)
        else:
            vent = shapes.box((0.5, 0.02, 0.16), bevel=0.005)
            place(into, [(vent, "hull", colors.STONE_WORN, atlas.fit("vent")(vent))],
                  (out[0] * half, out[1] * half, 0.07), turn)
    door = hatches.door(atlas, 0.2, 0.2, colour=colors.STONE, seed=3)
    place(into, door, (-0.28, -half - 0.005, 0.0))
    _capacitors(into, atlas, (-0.4, 0.4))
    _cables(into, atlas)
    for x, y, size in ((0.55, -0.62, 0.8), (-0.62, 0.55, 0.75), (0.66, 0.5, 0.55),
                       (-0.6, -0.62, 0.6)):
        reef.cluster(into, rng, atlas, (x, y, 0), size, 3)
    tops = reef.around(rng, 0.42, 0.56, 4, 0.18, arcs=((-60, 30), (150, 200)), z=HEIGHT * 0.96)
    reef.grow(into, rng, atlas, tops, reef.SMALL)


def _gauges(into, atlas, at, turn, seed):
    """A panel of five charge gauges, gold, the last ones dimmed."""
    plate = shapes.box((0.42, 0.02, 0.12), bevel=0.006)
    parts = [(plate, "hull", machined(colors.HULL_DARK, 20 + seed, soot=0.0), atlas.fit("plate_wide")(plate))]
    for i in range(5):
        bar = shapes.box((0.05, 0.012, 0.06)).transform((-0.16 + i * 0.08, -0.012, 0.03))
        parts.append((bar, *light(atlas, "gold" if i < 4 else "rust")))
    place(into, parts, (at[0], at[1], 0.14), turn)


def _capacitors(into, atlas, at):
    """Three upright drums of capacitors banded in gold, and a crate."""
    for k, (dx, dy) in enumerate(((0.0, 0.0), (0.13, 0.03), (0.05, -0.12))):
        parts = props.drum(atlas, 0.06, 0.2, colour=colors.HULL_DARK, seed=30 + k)
        ring = shapes.cylinder(0.063, 0.02, sides=10, bottom=False).transform((0, 0, 0.16))
        parts.append((ring, *light(atlas, "gold")))
        place(into, parts, (at[0] + dx, at[1] + dy, HEIGHT - 0.012))
    place(into, props.crate(atlas, (0.16, 0.12, 0.1), seed=33), (0.36, 0.4, HEIGHT - 0.012),
          (0, 0, 0.3))


def _cables(into, atlas):
    """Conduits down the housing's south face to the deck, toward the avenue."""
    for k, x in enumerate((-0.09, -0.04)):
        path = [(x, -0.5, HEIGHT - 0.02), (x, -0.64, HEIGHT - 0.06), (x, -0.66, 0.1),
                (x - 0.03, -0.8, 0.02), (x - 0.1, -0.95, 0.01)]
        place(into, plumbing.pipe(atlas, path, 0.022, colors.PIPE if k else colors.HULL_DARK,
                                  flanges=1, seed=k, sides=6))

