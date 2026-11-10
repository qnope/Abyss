"""Small sessile life: anemones with glowing tips, shells and sea stars."""

import math

from mathutils import Vector

from catalog import colors, paints
from workshop import shapes, sweep
from workshop.colors import scale, vary
from workshop.geometry import Geometry


def anemone(rng, size, glowing=True):
    base = vary(rng.choice((colors.ANEMONE, colors.CORAL_PINK, colors.CORAL_ORANGE)), rng)
    body = sweep.lathe([(0.1, -0.02), (0.09, 0.08), (0.11, 0.14), (0.14, 0.17), (0.0, 0.16)],
                       sides=10)
    arms, tips = Geometry(), Geometry()
    count = rng.randrange(8, 11)
    for k in range(count):
        a = 2 * math.pi * k / count + rng.uniform(-0.1, 0.1)
        out = Vector((math.cos(a), math.sin(a), 0))
        reach = rng.uniform(0.14, 0.22)
        path = [out * 0.1 + Vector((0, 0, 0.16)), out * (0.1 + reach * 0.5) + Vector((0, 0, 0.26)),
                out * (0.1 + reach) + Vector((0, 0, 0.3 + rng.uniform(-0.04, 0.06)))]
        arms.extend(sweep.tube(path, [0.018, 0.013, 0.008], sides=3))
        tips.extend(shapes.octahedron(0.016).transform(path[-1]))
    parts = [(body, "coral", paints.organic(scale(base, 0.5), base, 3)),
             (arms, "coral", paints.organic(base, scale(base, 1.5), 4))]
    if glowing:
        parts.append((tips, "glow_pink", colors.GLOW_PINK))
    return [(g.transform(scale=size), m, p) for g, m, p in parts]


def scallop(rng, size):
    """A ribbed fan shell lying on the ground."""
    geometry = Geometry()
    rings, spokes = 4, 13
    geometry.verts.append(Vector((0, 0, 0.01)))
    for i in range(1, rings + 1):
        r = i / rings
        for k in range(spokes):
            a = math.radians(-75 + 150 * k / (spokes - 1))
            rib = 0.025 * abs(math.sin(k * math.pi / 2)) * r
            geometry.verts.append(Vector((math.cos(a) * r, math.sin(a) * r * 1.05,
                                          0.18 * math.sin(math.pi * r * 0.9) * (1 - abs(a) / 2) + rib)))
    for k in range(spokes - 1):
        geometry.faces.append((0, k + 2, k + 1))
    for i in range(rings - 1):
        for k in range(spokes - 1):
            a, b = 1 + i * spokes + k, 1 + (i + 1) * spokes + k
            geometry.faces.append((a, a + 1, b + 1, b))
    geometry.smooth = [True] * len(geometry.faces)
    geometry.transform((0, 0, 0), (0, 0, rng.uniform(0, 6.28)), scale=size)
    color = vary(rng.choice((colors.SHELL, colors.CORAL_ORANGE, colors.SHELL)), rng, 0.1)
    return [(geometry, "coral", paints.organic(scale(color, 0.8), color, 5, frequency=12))]


def sea_star(rng, size):
    outline = []
    for k in range(10):
        a = math.pi * k / 5
        r = 1.0 if k % 2 == 0 else 0.38
        outline.append((math.cos(a) * r, math.sin(a) * r))
    star = shapes.prism(outline, 0.16, bevel=0.06, segments=1, top=0.85)
    star.transform((0, 0, -0.04), (0, 0, rng.uniform(0, 6.28)), scale=size)
    color = vary(rng.choice((colors.CORAL_ORANGE, colors.CORAL_PINK, colors.SPONGE_ORANGE)), rng)
    return [(star, "coral", paints.organic(scale(color, 0.7), color, 6))]
