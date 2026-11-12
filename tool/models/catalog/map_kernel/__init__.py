"""The volcano with the volcanic kernel at its heart: the great volcano of
the map, covering the 2 x 2 cells round its centre (the origin: where the four
cells meet, the floor under it). A faceted cone of black basalt, 2.0 high,
streaked with lava from its crater to its foot and clamped by iron bands,
obsidian prongs closing over the crater round the kernel itself, a molten orb
in an iron ring, which glows again through a breach in the front flank. The
colours and the materials of catalog/volcanic_kernel, the base's own kernel:
black rock, iron, orange and yellow fire. The tallest, widest and hottest
content of the map.

Tintable: Tint = the seal, a ring of light at the foot of the cone (neutral
white by default): the colour of the owner who holds the volcano. The game
shows it only for a held volcano and gives it the owner's colour.
Front toward -y."""

import math

from catalog import colors, mapkit
from catalog.map_kernel import cone
from catalog.parts import extrude, place
from catalog.parts.deep import IRON, ring_tube
from catalog.textures import map as tiles
from workshop import shapes

NAME = "map_kernel"
SEED = 7801
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("lava", "molten", "ember", "white", "basalt", "magma")
BUDGET = mapkit.budget(5_200)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY, mapkit.TINT]
OBSIDIAN = (0.025, 0.022, 0.035)


def build(model):
    atlas, rng, into = model.atlas, model.rng, mapkit.body(model)
    cone.rock(into, atlas, rng)
    cone.flows(into, atlas, 5, 0.2, 0.11)
    cone.rubble(into, atlas, rng)
    lake = shapes.cylinder(0.25, 0.02, sides=16, smooth=False).transform((0, 0, 1.6))
    into.add(lake, "lamp", colors.LAMP, atlas.tiled("magma", 0.4)(lake))
    kernel = shapes.sphere(0.21, subdivisions=2).transform((0, 0, 1.76), scale=(1, 1, 0.95))
    into.add(kernel, "lamp", colors.LAMP, atlas.tiled("magma", 0.4)(kernel))
    cage = ring_tube(0.3, 0.025, sides=6, points=28, tilt=(math.radians(16), math.radians(-8), 0)).transform((0, 0, 1.74))
    into.add(cage, "hull", IRON, atlas.solid("plain")(cage))
    for k in range(6):  # obsidian prongs closing over the crater
        a = math.pi / 6 + math.pi * k / 3
        prong = shapes.prism(shapes.polygon(5, 0.05, 0.3), 0.42, bevel=0.01, top=0.3, bottom=False)
        prong.transform((0, 0, 0), (0, math.radians(-14), 0)).transform((0.3, 0, 1.62), (0, 0, a))
        into.add(prong, "hull", OBSIDIAN, atlas.solid("plain")(prong))
    _heart(into, atlas)
    for k in range(9):
        a = 2 * math.pi * k / 9
        spark = shapes.octahedron(0.022).transform((0.5 * math.cos(a), 0.5 * math.sin(a), 1.72 + 0.09 * (k % 3)))
        into.add(spark, "lamp", colors.LAMP, atlas.solid("ember")(spark))
    seal = extrude.collar(1.0, 0.09, 0.05, sides=28)
    place(mapkit.tint(model), [(seal, "lamp", colors.LAMP, atlas.solid("white")(seal))])


def _heart(into, atlas):
    """A breach in the front flank, the molten kernel showing through it."""
    r = cone.radius_at(0.62)
    for tile, size in (("lava", 0.2), ("molten", 0.13)):
        orb = shapes.sphere(size, subdivisions=2).transform((0, -r + 0.02, 0.62), scale=(1.15, 0.7, 0.9))
        into.add(orb, "lamp", colors.LAMP, atlas.tiled("magma", 0.3)(orb) if tile == "lava" else atlas.solid(tile)(orb))
    for side in (-1, 1):
        tooth = shapes.prism(shapes.polygon(4, 0.05, 0.5), 0.3, top=0.2, bevel=0.01, bottom=False)
        tooth.transform((0, 0, 0), (math.radians(24), 0, 0)).transform((side * 0.2, -r + 0.02, 0.5), (0, 0, side * 0.3))
        into.add(tooth, "hull", OBSIDIAN, atlas.solid("plain")(tooth))
