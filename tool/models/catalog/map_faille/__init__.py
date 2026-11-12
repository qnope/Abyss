"""La Faille: a rift in the sea floor, a transition post toward the next
level. Two jagged plates of black basalt tilted up along a long crack of
violet light, shards of violet crystal along its lips, and standing in the
crack an upright lens of light, a portal with a white-hot core, over a cloud
of floating shards. Low and wide (0.7 high at the portal), the only violet
thing of the map; the ring of lights on the floor round it and the banner on a
mast, in the node Tint, wear the holder's colour.

Tintable: Tint = the ring and the banner (neutral white by default, the
guardians' grey in the game). Front toward -y."""

import math

from catalog import colors, mapkit
from catalog.mapkit import post
from catalog.parts.extrude import jagged
from catalog.parts.deep import BASALT, BASALT_LIGHT, paint_basalt
from catalog.textures import map as tiles
from workshop import shapes

NAME = "map_faille"
SEED = 7401
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("violet", "white", "basalt")
BUDGET = mapkit.budget(2_200)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY, mapkit.TINT]
GAP = 0.12  # half the width of the crack at its widest


def build(model):
    atlas, rng, into = model.atlas, model.rng, mapkit.body(model)
    for side in (-1, 1):
        for k, (x, size) in enumerate(((-0.2, 0.22), (0.18, 0.2))):
            plate = shapes.prism(jagged(rng, 7, 1.0, 0.25), 0.1 + 0.03 * k, bevel=0.012, bottom=False)
            plate.transform((0, 0, 0), scale=(size * 1.3, size * 0.62, 1))
            plate.transform((0, 0, 0), (0.2 * side, 0, 0))
            plate.transform((x, side * (GAP + 0.14), 0.0), (0, 0, 0.12 * side))
            into.add(plate, "reef", paint_basalt(k + 4 * side, BASALT, BASALT_LIGHT, warm=0.0),
                     atlas.tiled("basalt", 0.5)(plate))
        pillar = shapes.prism(jagged(rng, 6, 0.1, 0.2), 0.62, bevel=0.01, top=0.3, bottom=False)
        pillar.transform((0, 0, 0), (0, 0.2 * side, 0)).transform((side * 0.3, 0.02, 0.0))
        into.add(pillar, "reef", paint_basalt(9 + side, BASALT, BASALT_LIGHT, warm=0.3),
                 atlas.tiled("basalt", 0.4)(pillar))
    _crack(into, atlas)
    _portal(into, atlas, rng)
    post.marks(model, atlas, 0.47, (-0.42, -0.3), mast=0.6, sides=12)


def _crack(into, atlas):
    """The strip of violet light at the bottom of the crack, wider at the middle."""
    steps = 9
    upper = [(-0.46 + 0.92 * k / steps, GAP * math.sin(math.pi * k / steps) ** 0.6 + 0.02) for k in range(steps + 1)]
    outline = upper + [(x, -y) for x, y in reversed(upper)]
    strip = shapes.prism(outline, 0.02, smooth=False, bottom=False)
    into.add(strip, "lamp", colors.LAMP, atlas.solid("violet")(strip))


def _portal(into, atlas, rng):
    """An upright lens of light in the crack, a hot core, shards in the air."""
    for tile, scale_ in (("violet", (0.2, 0.03, 0.34)), ("white", (0.14, 0.036, 0.25))):
        lens = shapes.sphere(1.0, subdivisions=2).transform((0, 0, 0.36), scale=scale_)
        into.add(lens, "lamp", colors.LAMP, atlas.solid(tile)(lens))
    for k in range(7):
        a = 2 * math.pi * k / 7 + 0.4
        shard = shapes.octahedron(0.035).transform(
            (0.34 * math.cos(a), 0.12 * math.sin(a), 0.2 + 0.5 * ((k * 5) % 7) / 7), (0.3 * k, 0.2, 0.5 * k),
            scale=(0.6, 0.6, 1.6))
        into.add(shard, "lamp", colors.LAMP, atlas.solid("violet")(shard))
    for k in range(6):
        x = -0.4 + 0.16 * k
        spike = shapes.octahedron(0.05).transform((x, (GAP * 0.6) * (-1) ** k, 0.05), (0.2 * (-1) ** k, 0, 0),
                                                  scale=(0.6, 0.6, 2.0))
        into.add(spike, "lamp", colors.LAMP, atlas.solid("violet")(spike))
