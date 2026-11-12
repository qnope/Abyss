"""The laboratory's third tier, the institute: a slim ceramic tower behind the
hall, banded and windowed, its platform crowned by an atom of glowing rings
around a core (node Atom, which the game turns), its lamps ringed round it."""

import math

from mathutils import Vector

from catalog.paints import machined
from catalog.parts import command as c
from catalog.parts import place, rails, reef
from workshop import shapes, sweep

AT = (-0.05, 0.52)  # the tower's axis
PROFILE = [(0.36, 0.0), (0.31, 0.12), (0.27, 0.35), (0.25, 1.1), (0.28, 1.34), (0.3, 1.42),
           (0.0, 1.43)]
TOP = 1.43
ATOM = 1.98


def tier3(coll, model):
    atlas = model.atlas
    body = sweep.lathe(PROFILE, sides=12, phase=math.pi / 12, smooth=False)
    body.subdivide(0.3)
    coll.add(body.transform((*AT, 0)), "hull", machined(c.CERAMIC, 10, soot=0.3, height=0.6),
             atlas.fit("panel")(body))
    for z in (0.42, 0.86, 1.28):
        band = shapes.cylinder(0.28 - 0.02 * z, 0.05, sides=12, smooth=False, bevel=0.008)
        coll.add(band.transform((*AT, z)), "hull", machined(c.TEAL_TRIM, 11, soot=0.0),
                 atlas.fit("strap")(band))
    for k, a in enumerate((-90, -55, -125)):
        a = math.radians(a)
        r = 0.255 - 0.02
        for z in (0.82, 1.08):
            place(coll, c.window(atlas, 0.2, 0.17, "panes_teal"),
                  (AT[0] + r * math.cos(a) * 1.0, AT[1] + r * math.sin(a), z), (0, 0, a + math.pi / 2))
    _platform(coll, atlas)
    _atom(model, atlas)
    reef.cluster(coll, model.rng, atlas, (-0.68, 0.7, 0.0), 0.6, 2)


def _platform(coll, atlas):
    disc = shapes.cylinder(0.36, 0.05, sides=12, bevel=0.01, smooth=False, bottom=True)
    coll.add(disc.transform((*AT, TOP)), "hull", machined(c.TEAL_DARK, 12, soot=0.0),
             atlas.fit("tread")(disc))
    edge = [(AT[0] + 0.33 * math.cos(a), AT[1] + 0.33 * math.sin(a), TOP + 0.05)
            for a in (2 * math.pi * k / 12 for k in range(12))]
    place(coll, rails.railing(atlas, edge, 0.1))
    for k in range(8):
        a = 2 * math.pi * k / 8
        place(coll, c.lamp(atlas, "teal", (AT[0] + 0.36 * math.cos(a), AT[1] + 0.36 * math.sin(a),
                                           TOP + 0.02), 0.025))
    spindle = shapes.cylinder(0.035, ATOM - TOP - 0.05, sides=6, top_radius=0.02, bottom=False)
    coll.add(spindle.transform((*AT, TOP + 0.05)), "hull", c.ARMOR_DARK, atlas.solid("plain")(spindle))
    place(coll, c.lamp(atlas, "teal", (*AT, TOP + 0.12), 0.05))


def _atom(model, atlas):
    x, y = c.turned(AT)
    piece = model.piece("Laboratory/Tier3/Atom", (x, y, ATOM))
    piece.add(shapes.octahedron(0.075).transform(scale=(1, 1, 1.3)), "lamp", (0.3, 0.3, 0.3),
              atlas.solid("teal"))
    for k in range(3):
        a = k * math.pi / 3
        loop = []
        for i in range(17):
            t = 2 * math.pi * i / 16
            loop.append(Vector((0.3 * math.cos(t), 0.3 * math.sin(t), 0.0)))
        ring = sweep.tube(loop, [0.012] * 17, sides=4, cap=False)
        ring.transform(rotation=(math.radians(62), 0, a))
        piece.add(ring, "hull", c.CERAMIC_DARK, atlas.solid("plain")(ring))
        gem = shapes.octahedron(0.035).transform((0.3, 0, 0))
        gem.transform(rotation=(math.radians(62), 0, a))
        piece.add(gem, "lamp", (0.3, 0.3, 0.3), atlas.solid("teal"))
