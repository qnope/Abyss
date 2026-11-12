"""The barracks' third tier, the fortress: a taller keep tower at the right
end under its great banner, harpoon launchers on both towers, a crenellated
parapet round the hall's roof, a heavy portal before the door lit in red,
and anti-ram hedgehogs."""

from catalog.barracks.annex import LEFT, TOWER
from catalog.barracks.hall import FOOT, FRONT, ROOF, SIZE
from catalog.paints import machined
from catalog.parts import command as c
from catalog.parts import command_tech as t
from catalog.parts import place, reef
from workshop import shapes

KEEP = (0.46, 0.46, 1.36)
RIGHT = 0.62


def tier3(coll, model):
    atlas = model.atlas
    w, d, h = KEEP
    place(coll, t.tower(atlas, (w, d), h, seed=40), (RIGHT, 0.04, FOOT))
    top = FOOT + h + 0.1
    place(coll, c.banner(atlas, 0.3, 0.62, colour=c.CLOTH, seed=3), (RIGHT, 0.04 - d / 2 + 0.01, FOOT + 0.62))
    for z in (0.5, 1.0):
        place(coll, c.window(atlas, 0.08, 0.16, "ribbon_red"), (RIGHT + 0.12, 0.04 - d / 2 + 0.02, z + FOOT))
    place(coll, t.launcher(atlas, seed=4), (RIGHT, 0.04, top))
    place(coll, t.launcher(atlas, seed=5, tilt=0.5), (LEFT - 0.08, 0.04, FOOT + TOWER[2] + 0.1))
    place(coll, t.merlons(atlas, SIZE[0] * 0.5, SIZE[1] * 0.92, ROOF + 0.02, seed=6))
    _portal(coll, atlas)
    for x in (-0.55, 0.52):
        _hedgehog(coll, atlas, (x, FRONT - 0.1), x)
    reef.cluster(coll, model.rng, atlas, (0.8, -0.62, 0.0), 0.7, 3)


def _portal(coll, atlas):
    """Two pylons and a lintel before the door, a red light across it."""
    y = FRONT - 0.16
    for x in (-0.2, 0.2):
        pylon = shapes.box((0.1, 0.14, 0.52), bevel=0.012, bottom=False)
        place(coll, [(pylon, "hull", machined(c.ARMOR_DARK, 41, soot=0.3), atlas.fit("plate_tall")(pylon))],
              (x, y, FOOT))
        place(coll, c.lamp(atlas, "red", (x, y - 0.075, FOOT + 0.54), 0.035))
    lintel = shapes.box((0.54, 0.16, 0.1), bevel=0.014, bottom=False)
    place(coll, [(lintel, "hull", machined(c.ARMOR, 42, soot=0.1), atlas.fit("plate_wide")(lintel))],
          (0, y, FOOT + 0.46))
    place(coll, c.window(atlas, 0.4, 0.04, "ribbon_red"), (0, y - 0.082, FOOT + 0.49))


def _hedgehog(coll, atlas, at, seed):
    """Three crossed girders: an obstacle against rams."""
    for k, turn in enumerate(((0.6, 0.0, 0.5), (-0.6, 0.9, 2.0), (0.2, -0.8, 3.6))):
        girder = shapes.box((0.28, 0.035, 0.035), bevel=0.006).transform((0, 0, -0.0175), turn)
        place(coll, [(girder, "hull", machined(c.ARMOR_DARK, 43 + k, soot=0.2), atlas.fit("hazard")(girder))],
              (at[0], at[1], FOOT + 0.14), (0, 0, seed))
