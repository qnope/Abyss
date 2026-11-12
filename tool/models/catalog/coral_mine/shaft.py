"""The shaft: a collar ringed with hazard stripes round a pit whose floor
glows with the pink lode, the lattice headframe over it with its landing,
its sheave (the node Wheel) and the cable down to the skip, and the winch
house with its drum."""

import math

from catalog import colors
from catalog.paints import machined
from catalog.parts import Into, lattice, place, plumbing, production
from workshop import shapes, sweep
from workshop.colors import linear

PZ = 0.09  # the deck's top, above the pad
AT = (-0.1, 0.05)  # the shaft's axis
STEEL = linear("#a8909e")  # coral-stained steel
FRAME = (0.3, 0.14, 0.78)  # the headframe: half-side at its foot and head, height
WINCH = (-0.52, 0.56)


def shaft(model, group):
    atlas, into = model.atlas, Into(model, group)
    place(into, production.deck(atlas, strip="pink", seed=30))
    wall = sweep.lathe([(0.36, 0.0), (0.345, 0.16), (0.3, 0.17), (0.245, 0.17), (0.235, 0.0)], sides=16,
                       smooth=False)
    ring = sweep.lathe([(0.35, 0.172), (0.24, 0.172)], sides=16, smooth=False)
    floor = shapes.cylinder(0.24, 0.01, sides=16, bottom=False).transform((0, 0, 0.02))
    floor.faces = [f for i, f in enumerate(floor.faces) if floor.face_normal(i).z > 0.9]
    floor.smooth = [False] * len(floor.faces)
    place(into, [(wall, "hull", machined(colors.HULL_DARK, 31, soot=0.3), atlas.fit("plate")(wall)),
                 (ring, "hull", colors.WHITE, atlas.fit("hazard")(ring)),
                 (floor, "lamp", colors.LAMP, atlas.planar("veins_pink", (1, 0, 0), (0, 1, 0))(floor))],
          (*AT, PZ))
    _headframe(model, group, into, atlas)
    _winch(into, atlas)


def _headframe(model, group, into, atlas):
    base, top, height = FRAME
    x, y, z = AT[0], AT[1], PZ
    place(into, lattice.tower(atlas, base, top, height, 3, 0.012, STEEL, seed=32), (x, y, z))
    place(into, lattice.cap(atlas, top * 2 + 0.06, 0.04, colors.HULL, seed=33), (x, y, z + height))
    for side in (-1, 1):
        cheek = shapes.box((0.025, 0.03, 0.15), bevel=0.004, bottom=False)
        place(into, [(cheek, "hull", machined(colors.HULL_DARK, 34), atlas.fit("plate_tall")(cheek))],
              (x + side * 0.095, y, z + height + 0.04))
    wheel = model.piece(f"{group}/Wheel", (x, y, z + height + 0.15))
    place(wheel, production.wheel(atlas, 0.1, 6, 0.014, colors.HULL, seed=35))
    down = [(x, y, z + height + 0.05), (x + 0.005, y, z + 0.5), (x, y, z + 0.3)]
    place(into, plumbing.cable(down, 0.008, colors.GROOVE))
    skip = shapes.box((0.12, 0.1, 0.1), bevel=0.01, bottom=False)
    place(into, [(skip, "hull", machined(colors.PIPE, 36), atlas.fit("plate")(skip))], (x, y, z + 0.2))
    to_winch = [(x - 0.1, y, z + height + 0.15), (x - 0.25, (y + WINCH[1]) / 2, z + 0.4),
                (WINCH[0] + 0.24, WINCH[1], z + 0.17)]
    place(into, plumbing.cable(to_winch, 0.008, colors.GROOVE))


def _winch(into, atlas):
    x, y = WINCH
    house = shapes.box((0.34, 0.28, 0.17), bevel=0.012, bottom=False)
    roof = shapes.prism([(-0.19, -0.16), (0.19, -0.16), (0.19, 0.16), (-0.19, 0.16)], 0.06, top=0.8,
                        bevel=0.008, bottom=False).transform((0, 0, 0.17))
    drum = shapes.cylinder(0.06, 0.24, sides=10, bevel=0.006, bottom=False).transform(
        (0.24, 0.12, 0.1), (math.pi / 2, 0, 0))
    flange = [shapes.cylinder(0.085, 0.015, sides=10).transform((0.24, y0, 0.1), (math.pi / 2, 0, 0))
              for y0 in (-0.105, 0.135)]
    parts = [(house, "hull", machined(STEEL, 37, soot=0.4), atlas.fit("plate_wide")(house)),
             (roof, "hull", machined(colors.HULL_DARK, 38, soot=0.0), atlas.fit("tread")(roof)),
             (drum, "hull", machined(colors.PIPE, 39, soot=0.2), atlas.tiled("weathered", 0.4)(drum))]
    parts += [(f, "hull", colors.METAL_DARK, atlas.fit("bolt")(f)) for f in flange]
    place(into, parts, (x, y, PZ))
