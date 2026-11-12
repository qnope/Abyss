"""The laboratory's first tier, a field lab: a scrubbed ceramic hall on a low
plinth, its front a door between two lit windows, a row of glowing specimen
tanks outside, a skylight, a hatch and a mast on the roof."""

import math

from catalog import colors
from catalog.paints import machined
from catalog.parts import command as c
from catalog.parts import fittings, hatches, light, place, props, rails, reef
from workshop import shapes

HALL = (1.34, 0.86, 0.58)  # width, depth, height of the hall
FOOT = 0.12  # the plinth's height: the hall stands on it
ROOF = FOOT + HALL[2]
FRONT = -HALL[1] / 2


def tier1(coll, model):
    atlas = model.atlas
    plinth = shapes.prism(shapes.chamfered_square(1.74, 0.34), FOOT, bevel=0.02, bottom=False)
    plinth.subdivide(0.3)
    top, side = atlas.fit("tread")(plinth), atlas.fit("plate_wide")(plinth)
    coll.add(plinth, "hull", machined(c.CERAMIC_DARK, 1, soot=0.35),
             [top[i] if plinth.face_normal(i).z > 0.9 else side[i] for i in range(len(plinth.faces))])
    place(coll, c.slab(atlas, HALL, c.CERAMIC, tile="panel", top="panel", seed=2), (0, 0, FOOT))
    eave = shapes.box((HALL[0] + 0.1, HALL[1] + 0.1, 0.05), bevel=0.012, bottom=False)
    roof, trim = machined(c.CERAMIC_DARK, 3, soot=0.0), machined(c.TEAL_TRIM, 3, soot=0.0)
    coll.add(eave.transform((0, 0, ROOF - 0.01)), "hull",
             lambda p, n: roof(p, n) if n.z > 0.9 else trim(p, n), c.roof_uv(atlas, eave))
    _front(coll, atlas)
    _roof(coll, atlas)
    _tanks(coll, atlas)
    reef.cluster(coll, model.rng, atlas, (-0.78, -0.72, 0.0), 0.55, 2)


def _front(coll, atlas):
    place(coll, hatches.door(atlas, 0.22, 0.34, colour=c.CERAMIC_DARK, frame=c.TEAL_DARK, seed=1),
          (0.0, FRONT, FOOT))
    for x in (-0.4, 0.4):
        place(coll, c.window(atlas, 0.36, 0.24, "panes_teal"), (x, FRONT - 0.004, FOOT + 0.24))
        sill = shapes.box((0.42, 0.06, 0.03), bevel=0.008, bottom=False)
        place(coll, [(sill, "hull", c.TEAL_DARK, atlas.solid("plain")(sill))],
              (x, FRONT - 0.02, FOOT + 0.22))
    for side in (-1, 1):
        for y in (-0.15, 0.2):
            place(coll, hatches.porthole(atlas, 0.06, "porthole_teal", seed=2),
                  (side * (HALL[0] / 2 + 0.004), y, FOOT + 0.32), (0, 0, side * math.pi / 2))
    for x in (-0.55, 0.55):
        place(coll, c.lamp(atlas, "teal", (x, FRONT - 0.03, ROOF - 0.08)))


def _roof(coll, atlas):
    sky = shapes.box((0.34, 0.24, 0.07), bevel=0.01, bottom=False)
    place(coll, [(sky, "hull", machined(c.CERAMIC_DARK, 4, soot=0.1), atlas.fit("panel")(sky))],
          (0.32, 0.16, ROOF + 0.02))
    glow = shapes.box((0.26, 0.17, 0.01), bottom=False)
    place(coll, [(glow, *light(atlas, "teal"))], (0.32, 0.16, ROOF + 0.09))
    hatch = shapes.box((0.16, 0.16, 0.025), bevel=0.006, bottom=False)
    place(coll, [(hatch, "hull", colors.STONE, atlas.fit("door")(hatch))], (-0.4, 0.2, ROOF + 0.02))
    place(coll, fittings.mast(atlas, 0.55, 0.022), (-0.58, 0.3, ROOF + 0.02))
    place(coll, c.lamp(atlas, "teal", (-0.58, 0.3, ROOF + 0.6)))
    place(coll, rails.ladder(atlas, ROOF - FOOT + 0.1), (0.62, -0.1, FOOT), (0, 0, -math.pi / 2))


def _tanks(coll, atlas):
    for k, (x, r, h) in enumerate(((0.38, 0.08, 0.28), (0.56, 0.08, 0.26), (0.74, 0.07, 0.22))):
        place(coll, c.tank(atlas, r, h, seed=k), (x, FRONT - 0.2, FOOT))
    place(coll, props.crate(atlas, (0.16, 0.12, 0.1), colour=c.CERAMIC_DARK, seed=5),
          (-0.62, FRONT - 0.2, FOOT), (0, 0, 0.3))
