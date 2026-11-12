"""Armoured works for the barracks (and the headquarters' bastions): battered
towers with their crenellated tops, merlons, harpoon launchers, weapon racks
and searchlights. Makers give (geometry, material, paint, uv) in their own
frame, standing on z = 0, front toward -y."""

import math

from mathutils import Vector

from catalog import colors
from catalog.paints import machined
from catalog.parts import light
from catalog.parts.command import ARMOR, ARMOR_DARK
from workshop import shapes, sweep


def sided(atlas, geometry, side="plate_tall", top="tread"):
    sides, tops = atlas.fit(side)(geometry), atlas.fit(top)(geometry)
    return [tops[i] if geometry.face_normal(i).z > 0.9 else sides[i] for i in range(len(geometry.faces))]


def merlons(atlas, width, depth, z, colour=ARMOR, step=0.17, size=0.075, seed=0):
    """A ring of merlons around the rectangle width x depth, at height [z]."""
    parts, spots = [], []
    for k in range(max(2, round(width / step))):
        x = -width / 2 + width * (k + 0.5) / max(2, round(width / step))
        spots += [(x, -depth / 2, 0.0), (x, depth / 2, 0.0)]
    for k in range(max(1, round(depth / step) - 1)):
        y = -depth / 2 + depth * (k + 1) / max(1, round(depth / step))
        spots += [(-width / 2, y, math.pi / 2), (width / 2, y, math.pi / 2)]
    for x, y, turn in spots:
        block = shapes.box((size, size * 0.7, size), bevel=0.01, bottom=False)
        block.transform((x, y, z), (0, 0, turn))
        parts.append((block, "hull", machined(colour, seed, soot=0.1), atlas.fit("plate")(block)))
    return parts


def tower(atlas, size, height, colour=ARMOR, seed=0, merlon=True):
    """A battered square tower, its overhanging top crenellated; [size] is
    (width, depth) at its foot. Its top is at z = height + 0.1."""
    w, d = size
    body = shapes.prism([(-w / 2, -d / 2), (w / 2, -d / 2), (w / 2, d / 2), (-w / 2, d / 2)], height,
                        bevel=0.015, top=0.84, bottom=False)
    body.subdivide(0.3)
    parts = [(body, "hull", machined(colour, seed, soot=0.35, height=0.5), sided(atlas, body))]
    lip = shapes.box((w * 0.84 + 0.12, d * 0.84 + 0.12, 0.08), bevel=0.012, bottom=False)
    lip.transform((0, 0, height - 0.02))
    parts.append((lip, "hull", machined(ARMOR_DARK, seed + 1, soot=0.0), sided(atlas, lip, "strap", "tread")))
    if merlon:
        parts += merlons(atlas, w * 0.84 + 0.08, d * 0.84 + 0.08, height + 0.06, colour, seed=seed + 2)
    return parts


def launcher(atlas, seed=0, tilt=0.6):
    """A twin harpoon launcher on a turntable, aiming toward -y and up."""
    base = shapes.cylinder(0.1, 0.07, sides=8, bevel=0.01, smooth=False)
    yoke = shapes.box((0.2, 0.13, 0.09), bevel=0.01, bottom=False).transform((0, 0, 0.07))
    parts = [(base, "hull", machined(ARMOR_DARK, seed, soot=0.0), atlas.fit("bolt")(base)),
             (yoke, "hull", machined(ARMOR, seed + 1, soot=0.0), atlas.fit("plate")(yoke))]
    for x in (-0.055, 0.055):
        direction = Vector((0, -math.cos(tilt), math.sin(tilt)))
        points = [Vector((x, 0, 0.14)) + direction * t for t in (-0.05, 0.12, 0.3)]
        barrel = sweep.tube(points, [0.026, 0.022, 0.02], sides=6, cap=False)
        parts.append((barrel, "hull", machined(colors.METAL_DARK, seed + 2, soot=0.0),
                      atlas.solid("plain")(barrel)))
        tip = shapes.octahedron(0.022).transform(points[-1] + direction * 0.01)
        parts.append((tip, *light(atlas, "red")))
    return parts


def rack(atlas, count=4, height=0.5, seed=0):
    """A weapon rack: two posts, a crossbar and [count] harpoons leaning in it."""
    parts = []
    for x in (-count * 0.045, count * 0.045):
        post = shapes.box((0.03, 0.05, height * 0.55), bottom=False).transform((x, 0, 0))
        parts.append((post, "hull", ARMOR_DARK, atlas.solid("plain")(post)))
    bar = shapes.box((count * 0.09 + 0.06, 0.04, 0.03), bottom=False).transform((0, 0, height * 0.3))
    parts.append((bar, "hull", ARMOR_DARK, atlas.solid("plain")(bar)))
    for k in range(count):
        x = (k - (count - 1) / 2) * 0.09
        shaft = sweep.tube([(x, 0.0, 0.02), (x, 0.04, height * 0.5), (x, 0.08, height)],
                           [0.012, 0.012, 0.01], sides=4, cap=False)
        parts.append((shaft, "hull", colors.LIMESTONE, atlas.solid("plain")(shaft)))
        tip = shapes.cylinder(0.026, 0.07, sides=4, top_radius=0.002, bottom=False)
        tip.transform((x, 0.08, height - 0.005))
        parts.append((tip, "hull", colors.TRIM, atlas.solid("plain")(tip)))
    return parts


def searchlight(atlas, seed=0):
    """A lamp on a post: a housing whose lens looks toward -y."""
    post = shapes.cylinder(0.025, 0.14, sides=6, bottom=False)
    housing = shapes.cylinder(0.07, 0.12, sides=8, bevel=0.008, smooth=False).transform(
        (0, 0, 0.0), (math.pi / 2, 0, 0)).transform((0, 0, 0.2))
    lens = shapes.cylinder(0.055, 0.01, sides=8).transform((0, 0, 0), (math.pi / 2, 0, 0))
    lens.transform((0, -0.122, 0.2))
    return [(post, "hull", ARMOR_DARK, atlas.solid("plain")(post)),
            (housing, "hull", machined(ARMOR, seed, soot=0.0), atlas.fit("bolt")(housing)),
            (lens, *light(atlas, "white"))]
