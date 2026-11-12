"""The barracks' first tier, a bunker hall: a long armoured hall with battered
walls on a low plinth, its door under a red lamp between lit slits, a banner
on its pole, a rack of harpoons, drums and crates against it."""

from catalog import colors
from catalog.paints import machined
from catalog.parts import command as c
from catalog.parts import command_tech as t
from catalog.parts import fittings, hatches, place, props, reef
from workshop import shapes

FOOT = 0.14  # the plinth (the parade ground's plot hides the lowest 0.12)
SIZE = (1.56, 0.66, 0.5)  # the hall at its foot, and its height
ROOF = FOOT + SIZE[2]
FRONT = -SIZE[1] / 2


def tier1(coll, model):
    atlas = model.atlas
    plinth = shapes.prism(c.chamfered_rect(1.84, 1.1, 0.22), FOOT, bevel=0.02, bottom=False)
    plinth.subdivide(0.3)
    coll.add(plinth, "hull", machined(c.ARMOR_DARK, 20, soot=0.4), t.sided(atlas, plinth, "plate_wide", "tread"))
    w, d = SIZE[0] / 2, SIZE[1] / 2
    hall = shapes.prism([(-w, -d), (w, -d), (w, d), (-w, d)], SIZE[2], bevel=0.015, top=0.92,
                        bottom=False)
    hall.subdivide(0.3)
    place(coll, [(hall, "hull", machined(c.ARMOR, 21, soot=0.35, height=0.4),
                  t.sided(atlas, hall, "plate_wide", "plate"))], (0, 0, FOOT))
    _front(coll, atlas)
    _roof(coll, atlas)
    _yard(coll, atlas)
    reef.cluster(coll, model.rng, atlas, (0.8, -0.62, 0.0), 0.5, 2)


def _front(coll, atlas):
    place(coll, hatches.door(atlas, 0.22, 0.32, colour=c.ARMOR_DARK, frame=c.ARMOR_DARK, seed=3),
          (0.0, FRONT + 0.0, FOOT))
    for x in (-0.45, -0.22, 0.22, 0.45):
        place(coll, c.window(atlas, 0.15, 0.1, "panes_amber"), (x, FRONT - 0.0075, FOOT + 0.24))
    for x in (-0.76, 0.76):
        place(coll, c.lamp(atlas, "red", (x, FRONT - 0.02, ROOF - 0.06), 0.035))


def _roof(coll, atlas):
    cap = shapes.box((SIZE[0] * 0.92 + 0.04, SIZE[1] * 0.92 + 0.04, 0.04), bevel=0.01, bottom=False)
    coll.add(cap.transform((0, 0, ROOF - 0.02)), "hull", machined(c.ARMOR_DARK, 22, soot=0.0),
             t.sided(atlas, cap))
    for x in (-0.4, 0.3):
        hatch = shapes.box((0.16, 0.16, 0.025), bevel=0.006, bottom=False)
        place(coll, [(hatch, "hull", colors.STONE, atlas.fit("door")(hatch))], (x, 0.0, ROOF + 0.01))
    vent = shapes.box((0.22, 0.12, 0.08), bevel=0.01, bottom=False)
    place(coll, [(vent, "hull", colors.STONE_WORN, atlas.fit("vent")(vent))], (0.62, 0.1, ROOF + 0.01))
    place(coll, fittings.mast(atlas, 0.5, 0.02, colour=c.ARMOR_DARK), (-0.7, 0.18, ROOF))
    place(coll, c.lamp(atlas, "red", (-0.7, 0.18, ROOF + 0.55)))


def _yard(coll, atlas):
    place(coll, c.banner(atlas, 0.24, 0.4, pole=0.95, seed=1), (-0.72, -0.5, FOOT))
    place(coll, t.rack(atlas, 4, 0.5, seed=2), (0.62, -0.46, FOOT))
    place(coll, props.drum(atlas, 0.07, 0.17, colour=c.ARMOR, seed=4), (0.3, -0.5, FOOT))
    place(coll, props.crate(atlas, (0.2, 0.14, 0.12), colour=c.CLOTH_DARK, seed=5), (-0.3, -0.5, FOOT), (0, 0, 0.2))
