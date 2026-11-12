"""Tier 2 of the volcanic kernel, what rising adds: six leaning pillars of
basalt caging the crater, each hooped in iron and split by a slit of fire, a
spire of lava rising from the core in an iron ring, pipes feeding the mound and the reef gone hardy at its foot."""

import math

from catalog import colors
from catalog.parts import Into, place, plumbing, reef
from catalog.parts.deep import BASALT, BASALT_LIGHT, IRON, around, lamp, paint_basalt, ring_tube, swell
from catalog.volcanic_kernel import mound
from workshop import shapes, sweep

PILLAR_R = 0.52  # where the pillars stand
HEIGHTS = (1.0, 0.85, 1.0, 0.85, 1.0, 0.85)  # above the crater rim
REEF = ((0.92, -0.5, 0.7), (-0.55, -0.92, 0.7))


def tier2(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    for k, (x, y, a) in enumerate(around(6, PILLAR_R, phase=math.radians(30))):
        _pillar(into, atlas, x, y, a, HEIGHTS[k], k)
    spire = sweep.lathe([(0.1, 0.8), (0.15, 1.0), (0.12, 1.2), (0.08, 1.4), (0.03, 1.55), (0.0, 1.62)], sides=10)
    into.add(spire, "lamp", colors.LAMP, atlas.tiled("magma", 0.35)(spire))
    cage = ring_tube(0.21, 0.03, sides=6, points=24).transform((0, 0, 1.12))
    into.add(cage, "hull", IRON, atlas.solid("plain")(cage))
    for a in (0.4, 2.5, 4.4):
        r = mound.PROFILE[2][0]
        place(into, plumbing.pipe(atlas, [(0.97 * math.cos(a), 0.97 * math.sin(a), 0.06),
                                          (1.02 * math.cos(a), 1.02 * math.sin(a), 0.3),
                                          (r * math.cos(a), r * math.sin(a), 0.36)],
                                  0.035, colors.METAL_DARK, flanges=1, seed=int(a * 10)))
    for x, y, size in REEF:
        reef.cluster(into, rng, atlas, (x, y, 0.0), size * 0.8, 2)
    for k in range(8):
        a = 2 * math.pi * k / 8 + 0.2
        place(into, lamp(atlas, "lava", 0.025), (0.46 * math.cos(a), 0.46 * math.sin(a), 0.7))


def _pillar(into, atlas, x, y, azimuth, height, k):
    """A tapering column, leaning in toward the core, with an iron hoop and a
    glowing slit on its outer face."""
    column = shapes.prism(shapes.polygon(6, 0.115, 0.3), height, bevel=0.02, top=0.7, bottom=False)
    column.transform((0, 0, 0), (0, math.radians(-4), 0))
    column.subdivide(0.14)
    swell(column, 20 + k, 0.025, 0.14)
    column.transform((x, y, mound.RIM - 0.04), (0, 0, azimuth))
    into.add(column, "reef", paint_basalt(20 + k, BASALT, BASALT_LIGHT, warm=0.7), atlas.tiled("basalt", 0.6)(column))
    hoop = shapes.cylinder(0.14, 0.05, sides=6, top_radius=0.135, smooth=False)
    place(into, [(hoop, "hull", IRON, atlas.solid("plain")(hoop))],
          (x - 0.03 * math.cos(azimuth), y - 0.03 * math.sin(azimuth), mound.RIM - 0.04 + height * 0.55), (0, 0, azimuth))
    slit = shapes.box((0.025, 0.012, height * 0.4), bottom=False)
    reach = PILLAR_R + 0.095
    place(into, [(slit, "lamp", colors.LAMP, atlas.solid("lava")(slit))],
          (reach * math.cos(azimuth), reach * math.sin(azimuth), mound.RIM - 0.04 + height * 0.18),
          (0, 0, azimuth + math.pi / 2))
