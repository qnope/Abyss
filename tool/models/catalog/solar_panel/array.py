"""The tracking array, the node Array: on the housing's turntable, a mast
with a yoke and an axle, two wings of 3 x 3 modules on a spine, ribs and
struts under them, a piston holding their tilt, and the gold collector on
the top edge. Its origin on the turntable: the game turns it about z."""

import math

from mathutils import Matrix, Vector

from catalog import colors
from catalog.paints import machined
from catalog.parts import Into, light, place, plumbing
from catalog.solar_panel.housing import HEIGHT
from workshop import shapes, sweep

PIVOT, TILT, YAW = 0.68, math.radians(30), math.radians(45)  # facing the game's camera
MODULE, COLUMNS, ROWS, SPINE = (0.26, 0.34), 3, 3, 0.12


def array(model, group):
    atlas, into = model.atlas, Into(model, group)
    ring = shapes.cylinder(0.3, 0.05, sides=16, bevel=0.008, bottom=False)
    into.add(ring.transform((0, 0, HEIGHT - 0.01)), "hull", machined(colors.HULL_DARK, 40, soot=0.0),
             atlas.fit("bolt"))
    glow = shapes.cylinder(0.305, 0.014, sides=16, bottom=False).transform((0, 0, HEIGHT + 0.012))
    into.add(glow, *light(atlas, "gold"))
    piece = model.piece(f"{group}/Array", (0, 0, HEIGHT + 0.04))
    place(piece, _mast(atlas), rotation=(0, 0, YAW))
    place(piece, _wings(atlas), (0, 0, PIVOT), (TILT, 0, YAW))
    turn = Matrix.Rotation(YAW, 3, "Z") @ Matrix.Rotation(TILT, 3, "X")
    for side in (-1, 1):
        start = Matrix.Rotation(YAW, 3, "Z") @ Vector((side * 0.06, -0.07, 0.24))
        end = turn @ Vector((side * 0.3, -0.26, 0.0)) + Vector((0, 0, PIVOT))
        middle = start.lerp(end, 0.5)
        place(piece, plumbing.pipe(atlas, [start, middle], 0.03, colors.HULL_DARK, 1, 41, 6))
        place(piece, plumbing.pipe(atlas, [middle, end], 0.018, colors.TRIM, 0, 42, 6))


def _mast(atlas):
    top = shapes.cylinder(0.24, 0.05, sides=16, bevel=0.008, bottom=False)
    column = shapes.cylinder(0.085, PIVOT - 0.05, sides=8, top_radius=0.07,
                             bottom=False).transform((0, 0, 0.05))
    parts = [(top, "hull", machined(colors.HULL, 43, soot=0.0), atlas.fit("bolt")(top)),
             (column, "hull", machined(colors.HULL, 44, soot=0.0), atlas.tiled("weathered", 0.4)(column))]
    for x in (-0.11, 0.11):
        cheek = shapes.box((0.03, 0.14, 0.2), bevel=0.008).transform((x, 0, PIVOT - 0.12))
        parts.append((cheek, "hull", machined(colors.HULL_DARK, 45), atlas.fit("plate_tall")(cheek)))
    axle = shapes.cylinder(0.035, 0.32, sides=8).transform((0, 0, -0.16), (0, math.pi / 2, 0))
    parts.append((axle.transform((0, 0, PIVOT)), "hull", colors.TRIM, None))
    return parts


def _wings(atlas):
    """The wings in their own plane (z = 0 at the axle), spread along x."""
    width, depth = MODULE
    parts = []
    for side in (-1, 1):
        for c in range(COLUMNS):
            for r in range(ROWS):
                x = side * (SPINE / 2 + (c + 0.5) * (width + 0.01))
                y = (r - (ROWS - 1) / 2) * (depth + 0.01)
                parts += _module(atlas, (x, y, 0.07))
    reach = SPINE / 2 + COLUMNS * (width + 0.01)
    length = ROWS * (depth + 0.01)
    spine = shapes.box((SPINE, length + 0.08, 0.07), bevel=0.01).transform((0, 0, 0.0))
    parts.append((spine, "hull", machined(colors.HULL_DARK, 46, soot=0.0), atlas.fit("strap")(spine)))
    for r in (-1, 1):
        rib = shapes.box((2 * reach, 0.03, 0.04)).transform((0, r * length / 4, 0.03))
        parts.append((rib, "hull", colors.HULL_DARK, None))
        for side in (-1, 1):  # the wing's edge beams
            x = side * (reach + 0.015)
            edge = shapes.box((0.03, length + 0.03, 0.05), bevel=0.006).transform((x, 0, 0.025))
            parts.append((edge, "hull", machined(colors.HULL_DARK, 47, soot=0.0), atlas.fit("strap")(edge)))
            y = r * (length / 2 + 0.015)
            lip = shapes.box((reach - SPINE / 2, 0.03, 0.05), bevel=0.006)
            lip.transform((side * (reach + SPINE / 2) / 2, y, 0.025))
            parts.append((lip, "hull", colors.HULL_DARK, None))
    parts += _strands(length, reach)
    for side in (-1, 1):
        for end in (-1, 1):
            strut = sweep.tube([(side * 0.08, 0, 0.0), (side * reach * 0.85, end * length * 0.42, 0.05)],
                               [0.012, 0.01], sides=4, cap=False)
            parts.append((strut, "hull", colors.TRIM, None))
    stalk = sweep.tube([(0, length / 2, 0.06), (0, length / 2 + 0.06, 0.2)], [0.025, 0.018], sides=6,
                       cap=False)
    halo = sweep.tube([(0.12 * math.cos(a), length / 2 + 0.06, 0.28 + 0.12 * math.sin(a))
                       for a in (2 * math.pi * k / 12 for k in range(13))], [0.012] * 13, sides=4,
                      cap=False)
    lens = shapes.sphere(0.08, subdivisions=2).transform((0, length / 2 + 0.06, 0.28))
    strip = shapes.box((0.025, length, 0.012), bottom=False).transform((0, 0, 0.07))
    parts += [(stalk, "hull", colors.HULL_DARK, None), (halo, *light(atlas, "gold")),
              (lens, *light(atlas, "gold")), (strip, *light(atlas, "gold"))]
    return parts


def _module(atlas, at):
    """A module: an aluminium frame and its glazed cells."""
    width, depth = MODULE
    frame = shapes.box((width, depth, 0.03), bevel=0.006).transform((0, 0, -0.03))
    cells = shapes.box((width - 0.012, depth - 0.012, 0.004), bottom=False)
    cells.faces = [f for i, f in enumerate(cells.faces) if cells.face_normal(i).z > 0.9]
    cells.smooth = [False]
    parts = [(frame, "hull", colors.TRIM, atlas.solid("plain")(frame)),
             (cells, "glass", colors.WHITE, atlas.fit("solar", up=(0, 1, 0))(cells))]
    for geometry, *_ in parts:
        geometry.transform(at)
    return parts


def _strands(length, reach):
    """Algae caught on the wings' low edge, hanging and swaying."""
    parts = []
    for k, x in enumerate((-0.62, -0.31, 0.12, 0.47, 0.71)):
        drop = 0.16 + 0.07 * (k % 3)
        path = [Vector((x + 0.02 * math.sin(k + t * 3), -length / 2 - 0.02 - 0.03 * t, 0.03 - drop * t))
                for t in (0.0, 0.33, 0.66, 1.0)]
        strand = sweep.ribbon(path, [0.035, 0.03, 0.022, 0.006], [Vector((1, 0, 0))] * 4)
        parts.append((strand, "algae", colors.KELP if k % 2 else colors.ALGAE_TEAL, None))
    del reach
    return parts
