"""The nutrient basins in front of the glasshouse, kelp planted in them; the
second one under a trellis of ropes where kelp grows hung from orange
floats, and the harvest drone (the node Drone) hovering over it."""

import math

from mathutils import Vector

from catalog import colors
from catalog.algae_farm.hall import PZ
from catalog.decor import algae
from catalog.paints import machined
from catalog.parts import Into, dress, light, place, production
from workshop import shapes, sweep

SIZE = (0.64, 0.3)
FIRST, SECOND = (-0.4, -0.56), (-0.4, -0.22)


def first(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    place(into, production.basin(atlas, SIZE, colour=colors.HULL, seed=10), (*FIRST, PZ))
    for dx, h in ((-0.2, 0.3), (0.0, 0.22), (0.2, 0.34)):
        place(into, dress(algae.kelp(rng, h), atlas), (FIRST[0] + dx, FIRST[1], PZ + 0.04))


def second(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    place(into, production.basin(atlas, SIZE, colour=colors.HULL, seed=14), (*SECOND, PZ))
    for dx in (-0.2, 0.18):
        place(into, dress(algae.grass(rng, 0.2), atlas), (SECOND[0] + dx, SECOND[1] - 0.05, PZ + 0.04))
    _trellis(into, atlas)
    place(model.piece(f"{group}/Drone", (SECOND[0] + 0.1, SECOND[1] + 0.02, PZ + 0.5)), _drone(atlas))


def _trellis(into, atlas):
    """Two posts and two ropes over the basin, kelp hung from floats."""
    z = PZ + 0.34
    for x in (-0.72, -0.08):
        post = shapes.box((0.04, 0.04, 0.34), bevel=0.006, bottom=False)
        place(into, [(post, "hull", machined(colors.HULL_DARK, 15), atlas.fit("plate_tall")(post))],
              (x, SECOND[1] - 0.06, PZ))
        top = shapes.box((0.04, 0.2, 0.03), bevel=0.006).transform((x, SECOND[1] - 0.06, z))
        into.add(top, "hull", colors.HULL_DARK, atlas.solid("plain")(top))
    for y in (SECOND[1] - 0.14, SECOND[1] + 0.02):
        rope = sweep.tube([(-0.72, y, z + 0.02), (-0.4, y, z - 0.01), (-0.08, y, z + 0.02)],
                          [0.007] * 3, sides=4, cap=False)
        into.add(rope, "hull", colors.PIPE, atlas.solid("plain")(rope))
        for k in range(6):
            x = -0.64 + k * 0.1
            bulb = shapes.sphere(0.028, 1).transform((x, y, z + 0.01))
            into.add(bulb, "hull", colors.CORAL_ORANGE, atlas.solid("plain")(bulb))
            path = [Vector((x + 0.015 * math.sin(k + 2 * t), y, z - 0.02 - 0.2 * t)) for t in (0, 0.33, 0.66, 1)]
            strand = sweep.ribbon(path, [0.03, 0.045, 0.04, 0.012], [Vector((1, 0.3, 0))] * 4)
            into.add(strand, "algae", colors.KELP if k % 2 else colors.ALGAE_TEAL, None)


def _drone(atlas):
    """A quad-rotor with a scoop, a green lamp under its belly."""
    body = shapes.sphere(0.06, 1).transform((0, 0, 0), scale=(1, 1, 0.6))
    parts = [(body, "hull", machined(colors.TRIM, 16, soot=0.0), atlas.solid("plain")(body))]
    for k in range(4):
        a = math.pi / 4 + k * math.pi / 2
        end = (0.12 * math.cos(a), 0.12 * math.sin(a), 0.015)
        arm = sweep.tube([(0, 0, 0), end], [0.01, 0.008], sides=4, cap=False)
        rotor = shapes.cylinder(0.055, 0.006, sides=8).transform((end[0], end[1], 0.03))
        parts += [(arm, "hull", colors.HULL_DARK, None), (rotor, "hull", colors.LIMESTONE, atlas.solid("plain")(rotor))]
    scoop = shapes.cylinder(0.03, 0.04, sides=6, top_radius=0.012).transform((0, 0, -0.1))
    parts += [(scoop, "hull", colors.HULL_DARK, None), (shapes.octahedron(0.022).transform((0, 0, -0.045)),
                                                      *light(atlas, "green"))]
    return parts
