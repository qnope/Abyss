"""The plant beside the rig (Tier1): the engine block with its stack and its
blue gauges, a pressure tank on cradles piped to the rig, crates, lamps,
the ore breaking out in crystals, and the reef at the pad's corners."""

import math

from catalog import colors
from catalog.ore_extractor.rig import AT, PZ
from workshop.colors import linear
from catalog.paints import machined
from catalog.parts import Into, crystals, fittings, glasshouse, light, place, plumbing, props, reef
from workshop import shapes

SAFETY = linear("#e8a838")
ENGINE = (0.42, -0.44)
TANK = (-0.12, -0.62)


def plant(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    _engine(into, atlas)
    capsule(into, atlas, TANK, 0.11, 0.36, 80)
    pipe = [(TANK[0] + 0.1, TANK[1] + 0.1, PZ + 0.3), (TANK[0] + 0.1, TANK[1] + 0.3, PZ + 0.34),
            (AT[0] + 0.02, AT[1] - 0.3, PZ + 0.3)]
    place(into, plumbing.pipe(atlas, pipe, 0.024, colors.PIPE, flanges=1, seed=81, sides=6))
    place(into, crystals.cluster(atlas, rng, 7, 0.75, "blue"), (-0.52, 0.34, PZ))
    place(into, crystals.cluster(atlas, rng, 5, 0.42, "blue"), (0.4, 0.6, PZ))
    place(into, props.crate(atlas, (0.12, 0.1, 0.1), colors.PIPE, seed=82), (0.05, -0.68, PZ), (0, 0, 0.2))
    place(into, props.drum(atlas, 0.05, 0.13, colors.CORAL_ORANGE, seed=83), (0.7, -0.05, PZ))
    place(into, fittings.beacon(atlas, 0.035, "blue", seed=84), (0.72, 0.5, PZ))
    place(into, fittings.beacon(atlas, 0.035, "amber", seed=85), (-0.72, -0.2, PZ))
    for x, y, size in ((0.76, -0.76, 0.85), (-0.77, -0.77, 0.75), (0.77, 0.76, 0.7)):
        reef.cluster(into, rng, atlas, (x, y, 0), size, 3)


def capsule(into, atlas, at, radius, length, seed):
    """A pressure vessel lying along x on two cradles, banded in blue light."""
    x, y = at
    body = shapes.cylinder(radius, length, sides=12, bevel=0.0, smooth=True)
    body.transform((0, 0, 0), (0, math.pi / 2, 0)).transform((x - length / 2, y, PZ + radius + 0.05))
    parts = [(body, "hull", machined(colors.LIMESTONE, seed, soot=0.3, height=0.3),
              atlas.tiled("weathered", 0.5)(body))]
    for sign in (-1, 1):
        end = shapes.sphere(radius, 2).transform((x + sign * length / 2, y, PZ + radius + 0.05))
        parts.append((end, "hull", machined(colors.LIMESTONE, seed + 1, soot=0.3),
                      atlas.tiled("weathered", 0.5)(end)))
        cradle = shapes.box((0.04, radius * 2 + 0.03, 0.06), bevel=0.006, bottom=False)
        cradle.transform((x + sign * length * 0.3, y, PZ))
        parts.append((cradle, "hull", machined(colors.HULL_DARK, seed + 2), atlas.fit("plate")(cradle)))
        band = shapes.cylinder(radius * 1.06, 0.022, sides=12, smooth=False, bottom=False)
        band.transform((0, 0, 0), (0, math.pi / 2, 0)).transform((x + sign * length * 0.12, y, PZ + radius + 0.05))
        parts.append((band, *light(atlas, "blue")))
    place(into, parts)


def _engine(into, atlas):
    x, y = ENGINE
    body = shapes.box((0.36, 0.28, 0.22), bevel=0.016, bottom=False)
    vents = shapes.box((0.34, 0.31, 0.14), bevel=0.0).transform((0, 0, 0.05))
    vents.faces = [f for i, f in enumerate(vents.faces) if abs(vents.face_normal(i).y) > 0.9]
    vents.smooth = [False] * len(vents.faces)
    stack = shapes.cylinder(0.04, 0.28, sides=8, top_radius=0.03, bottom=False).transform((-0.12, 0.06, 0.25))
    parts = [(body, "hull", machined(SAFETY, 86, soot=0.3), atlas.fit("plate_wide")(body)),
             (vents, "hull", colors.STONE_WORN, atlas.fit("vent")(vents)),
             (stack, "hull", machined(colors.METAL_DARK, 87), atlas.tiled("weathered", 0.4)(stack)),
             (shapes.octahedron(0.026).transform((0.15, -0.16, 0.22)), *light(atlas, "blue"))]
    parts += glasshouse.pane_strip(atlas, (0.14, 0.02, 0.06), "panes_blue")
    parts[-1][0].transform((0.0, -0.152, 0.17))
    place(into, parts, (x, y, PZ), (0, 0, 0.12))
