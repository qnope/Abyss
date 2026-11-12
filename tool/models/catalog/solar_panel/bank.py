"""What the deck gains around the housing: battery cabinets of lit gold cells
along its west and north flanks (Tier2), and (Tier3) the collector, a tower
whose gold lens sits in rings of light, and gold-lit pylons."""

import math


from catalog import colors
from catalog.paints import machined
from catalog.parts import Into, fittings, light, place, plumbing
from mathutils import Vector
from catalog.solar_panel.housing import PZ
from workshop import shapes, sweep


def batteries(model, group):
    atlas, into = model.atlas, Into(model, group)
    for k, (at, turn, length) in enumerate((((0.64, 0.0), 0.0, 0.8), ((0.2, -0.64), 1.5708, 0.5))):
        body = shapes.box((0.2, length, 0.22), bevel=0.012, bottom=False)
        cap = shapes.box((0.22, length + 0.02, 0.03), bevel=0.008).transform((0, 0, 0.22))
        cells = shapes.box((0.202, length - 0.1, 0.12), bevel=0.0).transform((0, 0, 0.05))
        cells.faces = [f for i, f in enumerate(cells.faces) if abs(cells.face_normal(i).x) > 0.9]
        cells.smooth = [False] * len(cells.faces)
        place(into, [(body, "hull", machined(colors.HULL, 150 + k, soot=0.3), atlas.fit("plate_wide")(body)),
                     (cap, "hull", machined(colors.HULL_DARK, 152 + k, soot=0.0), atlas.fit("tread")(cap)),
                     (cells, "lamp", colors.LAMP, atlas.fit("panes_gold")(cells))],
              (at[0], at[1], PZ), (0, 0, turn))
    pipe = [(0.55, 0.3, PZ + 0.2), (0.52, 0.42, PZ + 0.3), (0.3, 0.5, PZ + 0.3)]
    place(into, plumbing.pipe(atlas, pipe, 0.022, colors.PIPE, 1, 154, 6))


def pylons(model, group):
    atlas, into = model.atlas, Into(model, group)
    for k, (x, y) in enumerate(((-0.68, 0.2), (0.5, 0.66), (0.66, -0.66))):
        post = shapes.cylinder(0.03, 0.45, sides=6, top_radius=0.02, bottom=False)
        place(into, [(post, "hull", machined(colors.HULL, 160 + k, soot=0.0), atlas.tiled("weathered", 0.4)(post))],
              (x, y, PZ))
        place(into, fittings.beacon(atlas, 0.04, "gold", seed=163 + k), (x, y, PZ + 0.45))
    for sx, sy in ((1, 1), (-1, 1), (-1, -1), (1, -1)):
        lamp = shapes.octahedron(0.032).transform((sx * 0.7, sy * 0.7, PZ + 0.03))
        into.add(lamp, *light(atlas, "gold"))


def collector(model, group):
    """The collector tower at the deck's back corner: a slim lattice mast
    holding a gold lens inside three rings, stayed to the deck."""
    atlas, into = model.atlas, Into(model, group)
    x, y = -0.62, -0.6
    mast = shapes.cylinder(0.05, 0.9, sides=8, top_radius=0.03, bottom=False)
    place(into, [(mast, "hull", machined(colors.HULL, 164, soot=0.0), atlas.tiled("weathered", 0.4)(mast))],
          (x, y, PZ))
    z = PZ + 0.98
    place(into, [(shapes.sphere(0.1, 2), *light(atlas, "gold"))], (x, y, z))
    for k, (radius, tilt) in enumerate(((0.19, 0.0), (0.25, 1.05), (0.25, -1.05))):
        ring = [Vector((radius * math.cos(a), radius * math.sin(a), 0)) for a in (2 * math.pi * i / 16 for i in range(17))]
        halo = sweep.tube(ring, [0.011] * 17, sides=4, cap=False)
        place(into, [(halo, *light(atlas, "gold"))], (x, y, z), (tilt, 0, k * 0.8))
    for k in range(3):
        a = 2 * math.pi * k / 3 + 0.5
        stay = sweep.tube([Vector((x, y, z - 0.3)), Vector((x + 0.3 * math.cos(a), y + 0.3 * math.sin(a), PZ))],
                          [0.007, 0.007], sides=4, cap=False)
        into.add(stay, "hull", colors.TRIM, atlas.solid("plain")(stay))
