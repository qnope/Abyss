"""The citadel's towers and gate: four round towers of grown stone with their
living cups, thorns and pink lanterns (the second tier), the gatehouse over
the north wall's gap (the first) and the reef at the foot of it all."""

import math

from catalog import colors
from catalog.coral_citadel.stone import grown, living, out_of, stone
from catalog.coral_citadel.walls import GATE, HALF, WALL
from catalog.paints import machined
from catalog.parts import Into, hatches, light, place, reef
from workshop import shapes, sweep

TOWER = [(0.26, -0.02), (0.25, 0.35), (0.22, 0.66), (0.23, 0.74), (0.0, 0.75)]
# The living cup each tower carries: (radius, height) out and back in.
CUP = [(0.2, 0.72), (0.27, 0.8), (0.32, 0.9), (0.3, 0.93), (0.23, 0.85), (0.0, 0.82)]
CORNERS = ((1, 1), (-1, 1), (-1, -1), (1, -1))
# The reef at the foot: (angle in degrees, distance, size), the front corner first.
CLUSTERS = ((-45, 1.12, 0.75), (-10, 1.0, 0.6), (-80, 1.0, 0.6), (45, 0.96, 0.5), (135, 1.0, 0.55),
            (200, 1.02, 0.55), (-130, 1.05, 0.6), (95, 0.95, 0.5), (-20, 0.96, 0.5))


def towers(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    for sx, sy in CORNERS:
        at = (sx * HALF, sy * HALF)
        seed = rng.randrange(1000)
        body = grown(sweep.lathe(TOWER, sides=12), seed, 0.022).transform((*at, 0))
        into.add(body, "reef", stone(rng, seed), atlas.tiled("coral", 1.0))
        cup = grown(sweep.lathe(CUP, sides=12), seed + 1, 0.015, 0.1).transform((*at, 0))
        into.add(cup, "reef", living(rng.randrange(99), 0.72, 0.93), atlas.tiled("coral", 1.0))
        band = shapes.cylinder(0.252, 0.05, sides=12, smooth=False).transform((*at, 0.4))
        into.add(band, "hull", machined(colors.HULL_DARK, seed, soot=0.0), atlas.fit("bolt"))
        out = out_of(*at)
        slit = shapes.box((0.05, 0.02, 0.14), bottom=False)
        place(into, [(slit, "lamp", colors.LAMP, atlas.fit("panes_pink")(slit))],
              (at[0] + out.x * 0.245, at[1] + out.y * 0.245, 0.2),
              (0, 0, math.atan2(out.y, out.x) + math.pi / 2))
        for k in range(5):
            a = 2 * math.pi * k / 5 + rng.uniform(0, 0.4)
            place(into, reef.thorn(atlas, rng, rng.uniform(0.16, 0.24), 0.03,
                                   (math.cos(a), math.sin(a), 0.6), colors.CORAL_DEEP, colors.CORAL_PINK),
                  (at[0] + 0.29 * math.cos(a), at[1] + 0.29 * math.sin(a), 0.88))
        spire = shapes.cylinder(0.06, 0.12, sides=6, top_radius=0.02, bottom=False)
        lantern = shapes.sphere(0.055, subdivisions=1).transform((0, 0, 0.17))
        place(into, [(spire, "hull", colors.HULL_DARK, None), (lantern, *light(atlas, "pink"))],
              (at[0], at[1], 0.82))


def gatehouse(model, group):
    """A block over the north wall's gap: an arch, its door, two lamps."""
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    seed = rng.randrange(1000)
    block = grown(shapes.box((GATE + 0.06, WALL[0] + 0.08, 0.6), bevel=0.02, bottom=False), seed, 0.02)
    into.add(block.transform((0, HALF, -0.02)), "reef", stone(rng, seed), atlas.tiled("coral", 1.0))
    door = hatches.door(atlas, 0.22, 0.3, colour=colors.HULL_DARK, seed=seed)
    place(into, door, (0, HALF + WALL[0] / 2 + 0.045, 0), (0, 0, math.pi))
    for x in (-0.19, 0.19):
        place(into, [(shapes.octahedron(0.035), *light(atlas, "pink"))], (x, HALF + 0.14, 0.42))


def clusters(model, group, which):
    """The reef clusters of CLUSTERS numbered [which]."""
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    for index in which:
        angle, distance, size = CLUSTERS[index]
        a = math.radians(angle)
        reef.cluster(into, rng, atlas, (distance * math.cos(a), distance * math.sin(a), 0), size, 2)
