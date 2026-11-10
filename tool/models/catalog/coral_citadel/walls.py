"""The citadel's curtain: four walls of grown stone between round towers,
merlons and thorns along their tops, a gatehouse in the north wall toward
the headquarters' spur, and the reef at their feet."""

import math

from catalog import colors
from catalog.coral_citadel.stone import grown, living, out_of, stone
from catalog.paints import machined
from catalog.parts import Into, hatches, light, place, reef
from workshop import shapes, sweep

HALF = 0.66  # the towers' centres, at (+-HALF, +-HALF)
WALL = (0.17, 0.42)  # thickness, height
TOWER = [(0.26, -0.02), (0.25, 0.35), (0.22, 0.66), (0.23, 0.74), (0.0, 0.75)]
# The living cup each tower carries: (radius, height) out and back in.
CUP = [(0.2, 0.72), (0.27, 0.8), (0.32, 0.9), (0.3, 0.93), (0.23, 0.85), (0.0, 0.82)]
GATE = 0.5  # the gatehouse's width


def walls(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    for k in range(4):
        angle = k * math.pi / 2
        _wall(into, atlas, rng, angle, gate=(k == 1))
    for sx, sy in ((1, 1), (-1, 1), (-1, -1), (1, -1)):
        _tower(into, atlas, rng, (sx * HALF, sy * HALF))
    _gatehouse(into, atlas, rng)
    for k in range(9):
        a = math.radians((-45 + 45 * k) if k < 8 else -20) + rng.uniform(-0.12, 0.12)
        d = rng.uniform(1.0, 1.12) if k % 2 else HALF * 1.45
        reef.cluster(into, rng, atlas, (d * math.cos(a), d * math.sin(a), 0),
                     rng.uniform(0.5, 0.75), 2)


def _wall(into, atlas, rng, angle, gate):
    """The wall on the side facing [angle], between two towers."""
    thick, height = WALL
    length = 2 * HALF - 0.36
    side = length / 2 - GATE / 2
    pieces = [(-length / 4 - GATE / 4, side), (length / 4 + GATE / 4, side)] if gate else [(0.0, length)]
    turn = angle + math.pi / 2
    for offset, size in pieces:
        seed = rng.randrange(1000)
        body = shapes.box((size + 0.04, thick, height), bevel=0.02, bottom=False)
        body.displace(lambda p: (0, -p.y * 0.25 * max(p.z, 0) / height, 0))
        grown(body, seed, 0.025)
        x, y = HALF * math.cos(angle), HALF * math.sin(angle)
        along = (-math.sin(angle) * offset, math.cos(angle) * offset)
        body.transform((x + along[0], y + along[1], -0.02), (0, 0, turn))
        into.add(body, "reef", stone(rng, seed), atlas.tiled("coral", 1.0))
        for m in range(max(1, round(size / 0.2))):
            t = (m + 0.5) / max(1, round(size / 0.2)) - 0.5
            merlon = grown(shapes.box((0.09, thick * 0.8, 0.09), bevel=0.015, bottom=False),
                           seed + m, 0.012, 0.2)
            mx, my = x + along[0] - math.sin(angle) * t * size, y + along[1] + math.cos(angle) * t * size
            place(into, [(merlon, "reef", stone(rng, seed + m), atlas.tiled("coral", 1.0)(merlon))],
                  (mx, my, height - 0.025), (0, 0, turn))
        for t in (-0.25, 0.25):
            px = x + along[0] - math.sin(angle) * t * size + math.cos(angle) * thick * 0.4
            py = y + along[1] + math.cos(angle) * t * size + math.sin(angle) * thick * 0.4
            out = out_of(math.cos(angle), math.sin(angle)) * 1.0
            out.z = 0.35
            place(into, reef.thorn(atlas, rng, rng.uniform(0.22, 0.3), 0.035, out,
                                   colors.CORAL_STONE, colors.CORAL_PINK), (px, py, height * 0.55))


def _tower(into, atlas, rng, at):
    seed = rng.randrange(1000)
    body = grown(sweep.lathe(TOWER, sides=12), seed, 0.022)
    body.transform((at[0], at[1], 0))
    into.add(body, "reef", stone(rng, seed), atlas.tiled("coral", 1.0))
    cup = grown(sweep.lathe(CUP, sides=12), seed + 1, 0.015, 0.1).transform((at[0], at[1], 0))
    into.add(cup, "reef", living(rng.randrange(99), 0.72, 0.93), atlas.tiled("coral", 1.0))
    band = shapes.cylinder(0.252, 0.05, sides=12, smooth=False).transform((at[0], at[1], 0.4))
    into.add(band, "hull", machined(colors.HULL_DARK, seed, soot=0.0), atlas.fit("bolt"))
    out = out_of(*at)
    slit = shapes.box((0.05, 0.02, 0.14), bottom=False)
    place(into, [(slit, "lamp", colors.LAMP, atlas.fit("panes_pink")(slit))],
          (at[0] + out.x * 0.245, at[1] + out.y * 0.245, 0.2),
          (0, 0, math.atan2(out.y, out.x) + math.pi / 2))
    for k in range(5):
        a = 2 * math.pi * k / 5 + rng.uniform(0, 0.4)
        spot = (at[0] + 0.29 * math.cos(a), at[1] + 0.29 * math.sin(a), 0.88)
        place(into, reef.thorn(atlas, rng, rng.uniform(0.16, 0.24), 0.03,
                               (math.cos(a), math.sin(a), 0.6), colors.CORAL_DEEP,
                               colors.CORAL_PINK), spot)
    spire = shapes.cylinder(0.06, 0.12, sides=6, top_radius=0.02, bottom=False)
    lantern = shapes.sphere(0.055, subdivisions=1).transform((0, 0, 0.17))
    place(into, [(spire, "hull", colors.HULL_DARK, None), (lantern, *light(atlas, "pink"))],
          (at[0], at[1], 0.82))


def _gatehouse(into, atlas, rng):
    """A block over the north wall's gap: an arch, its door, two lamps."""
    seed = rng.randrange(1000)
    block = grown(shapes.box((GATE + 0.06, WALL[0] + 0.08, 0.6), bevel=0.02, bottom=False), seed, 0.02)
    into.add(block.transform((0, HALF, -0.02)), "reef", stone(rng, seed), atlas.tiled("coral", 1.0))
    door = hatches.door(atlas, 0.22, 0.3, colour=colors.HULL_DARK, seed=seed)
    place(into, door, (0, HALF + WALL[0] / 2 + 0.045, 0), (0, 0, math.pi))
    for x in (-0.19, 0.19):
        lamp = shapes.octahedron(0.035)
        place(into, [(lamp, *light(atlas, "pink"))], (x, HALF + 0.14, 0.42))
