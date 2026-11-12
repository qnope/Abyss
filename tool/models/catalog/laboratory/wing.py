"""The laboratory's second tier, the research wing: a control room on the
hall's roof under its dish, a bioreactor sphere of glowing liquid in a cage
of rings, piped down into the hall, and the reef creeping up the plinth."""

import math

from mathutils import Vector

from catalog import colors
from catalog.laboratory.hall import FOOT, FRONT, ROOF
from catalog.paints import machined
from catalog.parts import command as c
from catalog.parts import fittings, light, place, plumbing, reef
from workshop import shapes, sweep

ROOM = (0.78, 0.5, 0.36)
SPHERE = (0.36, 0.08, ROOF + 0.42)  # x, y and z of the reactor's centre


def tier2(coll, model):
    atlas = model.atlas
    _room(coll, atlas)
    _reactor(coll, atlas)
    for k, (x, y, size) in enumerate(((0.72, -0.7, 0.6), (0.76, 0.5, 0.5), (-0.74, 0.55, 0.55))):
        reef.cluster(coll, model.rng, atlas, (x, y, 0.0), size, 2)
    ledge = reef.around(model.rng, 0.7, 0.86, 4, 0.2, arcs=((200, 340),), z=FOOT)
    reef.grow(coll, model.rng, atlas, ledge, reef.SMALL)


def _room(coll, atlas):
    x = -0.3
    place(coll, c.slab(atlas, ROOM, c.CERAMIC, tile="panel", top="panel", seed=6), (x, 0.0, ROOF + 0.03))
    top = ROOF + 0.03 + ROOM[2]
    eave = shapes.box((ROOM[0] + 0.1, ROOM[1] + 0.1, 0.05), bevel=0.012, bottom=False)
    roof, trim = machined(c.CERAMIC_DARK, 7, soot=0.0), machined(c.TEAL_TRIM, 7, soot=0.0)
    coll.add(eave.transform((x, 0, top - 0.01)), "hull",
             lambda p, n: roof(p, n) if n.z > 0.9 else trim(p, n), c.roof_uv(atlas, eave))
    place(coll, c.window(atlas, 0.6, 0.2, "ribbon_teal"), (x, -ROOM[1] / 2 - 0.004, ROOF + 0.17))
    for s in (-1, 1):
        place(coll, c.window(atlas, 0.3, 0.2, "panes_teal"), (x + s * (ROOM[0] / 2 + 0.004), 0, ROOF + 0.17),
              (0, 0, -s * math.pi / 2))
    place(coll, fittings.dish(atlas, 0.15, 0.07, colour=c.CERAMIC, seed=3), (x - 0.1, 0.0, top + 0.04),
          (0.5, 0, 0.5))
    place(coll, c.lamp(atlas, "teal", (x + 0.3, -0.2, top + 0.06)))


def _reactor(coll, atlas):
    x, y, z = SPHERE
    cradle = sweep.lathe([(0.0, 0.0), (0.2, 0.0), (0.22, 0.04), (0.16, 0.1), (0.0, 0.1)], sides=10)
    place(coll, [(cradle, "hull", machined(c.TEAL_DARK, 8, soot=0.0), atlas.fit("bolt")(cradle))],
          (x, y, ROOF - 0.02))
    ball = shapes.sphere(0.25, subdivisions=2).transform((x, y, z))
    coll.add(ball, *light(atlas, "teal"))
    for k in range(3):
        a = k * math.pi / 3
        loop = [Vector((0.27 * math.cos(t) * math.cos(a), 0.27 * math.cos(t) * math.sin(a),
                        0.27 * math.sin(t))) + Vector((x, y, z))
                for t in (2 * math.pi * i / 14 for i in range(15))]
        ring = sweep.tube(loop, [0.014] * 15, sides=4, cap=False)
        coll.add(ring, "hull", c.ARMOR_DARK, atlas.solid("plain")(ring))
    cap = shapes.cylinder(0.05, 0.05, sides=8).transform((x, y, z + 0.25))
    coll.add(cap, "hull", c.ARMOR_DARK, atlas.fit("bolt")(cap))
    path = [(x - 0.1, y + 0.1, ROOF + 0.1), (x - 0.22, y + 0.2, ROOF - 0.02),
            (x - 0.3, y + 0.34, ROOF - 0.3), (x - 0.34, y + 0.36, FOOT + 0.05)]
    place(coll, plumbing.pipe(atlas, path, 0.03, colors.PIPE, flanges=2, seed=2))
    gauge = shapes.cylinder(0.04, 0.02, sides=8).transform(rotation=(math.pi / 2, 0, 0))
    place(coll, [(gauge, *light(atlas, "teal"))], (0.62, FRONT - 0.005, FOOT + 0.3))
