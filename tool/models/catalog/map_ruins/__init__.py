"""The ruins: a drowned temple, the pale stone of an older people. A stepped
platform with four fluted columns, the two at the front standing under a
lintel (a lit teal orb floating between them), the two at the back broken to
stumps, a fallen drum and a cracked lintel lying before them, moss and
kelp creeping over the stone. The only pale, upright, columned thing of the
map (0.8 high): colour and rhythm of columns tell it from afar.

Not tintable. Front toward -y."""

import math

from catalog import colors, mapkit
from catalog.parts import fronds, place
from catalog.textures import map as tiles
from workshop import noise, shapes, sweep
from workshop.colors import linear, mix, scale

NAME = "map_ruins"
SEED = 7601
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("teal", "stone")
BUDGET = mapkit.budget(3_000)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY]
CREAM = linear("#ece0c8")
MOSS = linear("#2f8f6a")
STEP = 0.06


def stone(colour, seed):
    def paint(p, normal):
        base = scale(colour, 0.85 + 0.25 * noise.fbm(p * 5, seed, octaves=2))
        return mix(base, MOSS, max(0.0, 0.14 - p.z) * 3.0) if p.z < 0.14 else base
    return paint


def column(height, radius, seed, broken=False):
    """A column on z = 0 with a base and, whole, a capital; broken, a ragged stump."""
    r = radius
    profile = [(r * 1.35, 0.0), (r * 1.35, 0.04), (r, 0.06), (r * 0.95, height * 0.5)]
    if broken:
        profile += [(r * 0.85, height), (0.0, height)]
    else:
        profile += [(r * 0.82, height - 0.05), (r * 1.25, height - 0.04), (r * 1.4, height - 0.01),
                    (r * 1.4, height), (0.0, height)]
    shaft = sweep.lathe(profile, sides=10, smooth=False)
    if broken:
        shaft.displace(lambda p: (0, 0, 0.05 * noise.value(p * 9, seed) if p.z > height - 0.02 else 0))
    return shaft


def build(model):
    atlas, rng, into = model.atlas, model.rng, mapkit.body(model)
    for k, (radius, top) in enumerate(((0.46, STEP), (0.38, STEP * 2))):
        plinth = shapes.cylinder(radius, top, sides=8, bevel=0.01, smooth=False, bottom=False)
        into.add(plinth, "reef", stone(scale(CREAM, 0.85 - 0.1 * k), k), atlas.tiled("stone", 0.5)(plinth))
    for x, y, height, broken in ((-0.24, -0.18, 0.56, False), (0.24, -0.18, 0.56, False),
                                 (-0.24, 0.2, 0.3, True), (0.24, 0.2, 0.2, True)):
        shaft = column(height, 0.065, int(x * 10), broken).transform((x, y, STEP * 2))
        into.add(shaft, "reef", stone(CREAM, int(y * 9)), atlas.tiled("stone", 0.4)(shaft))
    top = STEP * 2 + 0.56
    lintel = shapes.box((0.62, 0.11, 0.07), bevel=0.01, bottom=False).transform((0, -0.18, top))
    into.add(lintel, "reef", stone(CREAM, 7), atlas.tiled("stone", 0.5)(lintel))
    fallen = shapes.box((0.3, 0.1, 0.06), bevel=0.01).transform((0.12, -0.4, 0.0), (0.05, 0.1, 0.5))
    into.add(fallen, "reef", stone(scale(CREAM, 0.9), 8), atlas.tiled("stone", 0.5)(fallen))
    drum = shapes.cylinder(0.065, 0.2, sides=10, smooth=False).transform((-0.2, -0.38, 0.065), (0, math.pi / 2, 0.4))
    into.add(drum, "reef", stone(CREAM, 9), atlas.tiled("stone", 0.4)(drum))
    orb = shapes.sphere(0.06, subdivisions=2).transform((0, -0.18, STEP * 2 + 0.32))
    into.add(orb, "lamp", colors.LAMP, atlas.solid("teal")(orb))
    for k in range(5):
        a = 2 * math.pi * k / 5 + 0.7
        place(into, fronds.tuft(atlas, rng, 0.2, colors.KELP_DARK), (0.4 * math.cos(a), 0.38 * math.sin(a), 0.02))
