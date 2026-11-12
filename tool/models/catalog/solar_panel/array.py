"""The tracking array, the node Array: on the housing's turntable, a mast
with a yoke and an axle, two wings of 3 x 2 modules on a spine with ribs and
struts, a piston holding their tilt, and a gold strip along the spine. It is
the same at every tier: it is what the game turns, about its own mast."""

import math

from mathutils import Matrix, Vector

from catalog import colors
from catalog.paints import machined
from catalog.parts import Into, light, place, plumbing
from catalog.solar_panel.housing import ROOF
from workshop import shapes, sweep

AT = (-0.06, 0.16, ROOF + 0.04)  # the turntable's centre
PIVOT, TILT, YAW = 0.5, math.radians(30), math.radians(45)  # above it, facing the camera
MODULE, COLUMNS, ROWS, SPINE, GAP = (0.22, 0.3), 3, 2, 0.12, 0.01
LENGTH = ROWS * (MODULE[1] + GAP)


def array(model, group):
    """The array as a piece of its own, its origin on the turntable."""
    atlas = model.atlas
    piece = model.piece(group, AT)
    top = shapes.cylinder(0.24, 0.05, sides=16, bevel=0.008, bottom=False)
    mast = shapes.cylinder(0.085, PIVOT - 0.05, sides=8, top_radius=0.07, bottom=False).transform((0, 0, 0.05))
    parts = [(top, "hull", machined(colors.HULL, 141, soot=0.0), atlas.fit("bolt")(top)),
             (mast, "hull", machined(colors.HULL, 142, soot=0.0), atlas.tiled("weathered", 0.4)(mast))]
    for x in (-0.11, 0.11):
        cheek = shapes.box((0.03, 0.14, 0.2), bevel=0.008).transform((x, 0, PIVOT - 0.12))
        parts.append((cheek, "hull", machined(colors.HULL_DARK, 143), atlas.fit("plate_tall")(cheek)))
    axle = shapes.cylinder(0.035, 0.32, sides=8).transform((0, 0, -0.16), (0, math.pi / 2, 0))
    parts.append((axle.transform((0, 0, PIVOT)), "hull", colors.TRIM, None))
    place(piece, parts, rotation=(0, 0, YAW))
    place(piece, _wing(atlas), (0, 0, PIVOT), (TILT, 0, YAW))
    turn = Matrix.Rotation(YAW, 3, "Z") @ Matrix.Rotation(TILT, 3, "X")
    for side in (-1, 1):
        start = Matrix.Rotation(YAW, 3, "Z") @ Vector((side * 0.06, -0.07, 0.24))
        end = turn @ Vector((side * 0.3, -0.26, 0.0)) + Vector((0, 0, PIVOT))
        middle = start.lerp(end, 0.5)
        place(piece, plumbing.pipe(atlas, [start, middle], 0.03, colors.HULL_DARK, 1, 144, 6))
        place(piece, plumbing.pipe(atlas, [middle, end], 0.018, colors.TRIM, 0, 145, 6))


def turntable(model, group):
    """The ring the array turns on, glowing gold: static, on the roof."""
    atlas, into = model.atlas, Into(model, group)
    ring = shapes.cylinder(0.3, 0.05, sides=16, bevel=0.008, bottom=False)
    into.add(ring.transform((AT[0], AT[1], ROOF - 0.01)), "hull", machined(colors.HULL_DARK, 140, soot=0.0),
             atlas.fit("bolt"))
    glow = shapes.cylinder(0.305, 0.014, sides=16, bottom=False).transform((AT[0], AT[1], ROOF + 0.012))
    into.add(glow, *light(atlas, "gold"))


def _wing(atlas):
    """The wings in their own plane (z = 0 at the axle), spread along x."""
    width, depth = MODULE
    reach = SPINE / 2 + COLUMNS * (width + GAP)
    parts = []
    for side in (-1, 1):
        for c in range(COLUMNS):
            for r in range(ROWS):
                x = side * (SPINE / 2 + (c + 0.5) * (width + GAP))
                parts += _module(atlas, (x, (r - (ROWS - 1) / 2) * (depth + GAP), 0.07))
        edge = shapes.box((0.03, LENGTH + 0.03, 0.05), bevel=0.006).transform((side * (reach + 0.015), 0, 0.025))
        parts.append((edge, "hull", machined(colors.HULL_DARK, 147, soot=0.0), atlas.fit("strap")(edge)))
        for end in (-1, 1):
            strut = sweep.tube([(side * 0.08, 0, 0.0), (side * reach * 0.85, end * LENGTH * 0.42, 0.05)],
                               [0.012, 0.01], sides=4, cap=False)
            parts.append((strut, "hull", colors.TRIM, None))
    spine = shapes.box((SPINE, LENGTH + 0.08, 0.07), bevel=0.01)
    strip = shapes.box((0.025, LENGTH, 0.012), bottom=False).transform((0, 0, 0.07))
    parts += [(spine, "hull", machined(colors.HULL_DARK, 148, soot=0.0), atlas.fit("strap")(spine)),
              (strip, *light(atlas, "gold"))]
    for r in (-1, 1):
        rib = shapes.box((2 * reach, 0.03, 0.04)).transform((0, r * LENGTH / 4, 0.03))
        lip = shapes.box((2 * reach - SPINE, 0.03, 0.05), bevel=0.006).transform((0, r * (LENGTH / 2 + 0.015), 0.025))
        parts += [(rib, "hull", colors.HULL_DARK, None), (lip, "hull", colors.HULL_DARK, None)]
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
