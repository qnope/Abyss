"""What crowns and covers the rampart: merlons of coral stone, glowing
polyps encrusting the faces of the blocks, and sprigs of coral growing in
the crenels."""

import math

from mathutils import Vector

from catalog import colors, paints
from catalog.base_rampart import masonry
from workshop import noise, shapes, sweep
from workshop.colors import scale, vary
from workshop.geometry import Geometry

POLYP = 0.042
LIFE = (colors.BRAIN_TAN, colors.BRAIN_ROSE, colors.BRAIN_OLIVE, colors.CRUST,
        colors.SPONGE_ORANGE, colors.ANEMONE)


def polyps(model, group, tops, rng, depth, height, chance=0.4):
    """Clusters of glowing polyps on both faces of the blocks under [tops],
    half way up their [height]."""
    dots = Geometry()
    for (x, y, z), length, turn in tops:
        for face in (-1, 1):
            if rng.random() > chance:
                continue
            along = rng.uniform(-length / 3, length / 3)
            for _ in range(rng.randrange(2, 4)):
                local = Vector((along + rng.uniform(-0.08, 0.08), face * depth / 2 * 0.97,
                                -height * rng.uniform(0.3, 0.7)))
                dot = shapes.octahedron(POLYP * rng.uniform(0.6, 1.2))
                dots.extend(dot.transform(_turned(local, turn) + Vector((x, y, z))))
    model.add(group, dots, "glow_pink", colors.GLOW_PINK)


def merlons(model, group, tops, rng, height, depth, keep):
    """A merlon on every other block under [tops] that [keep] allows: the
    ones skipped are the crenels, given back."""
    crenels = []
    for index, ((x, y, z), length, turn) in enumerate(tops):
        if not keep(x, y):
            continue
        if index % 2:
            crenels.append(((x, y, z), length, turn))
            continue
        size = (length * rng.uniform(0.55, 0.7), depth, height * rng.uniform(0.9, 1.1))
        block = masonry.stone(size, rng.randrange(1000), batter=0.18, rough=0.022)
        model.add(group, block.transform((x, y, z - 0.02), (0, 0, turn)), "coral",
                  masonry.coral_stone(rng, rng.randrange(1000)))
    return crenels


def encrust(model, group, tops, rng, depth, chance=0.4):
    """Lumps of brain coral and sponge grown over the edges of the blocks
    under [tops], hiding their joints."""
    for (x, y, z), length, turn in tops:
        if rng.random() > chance:
            continue
        seed, size = rng.randrange(1000), rng.uniform(0.11, 0.2)
        lump = shapes.sphere(1.0, subdivisions=1)
        lump.displace(lambda p: p.normalized() * 0.3 * noise.fbm(p * 1.6, seed, octaves=2))
        shapes.flatten_below(lump, -0.1, 0.2)
        side = rng.choice((-1, 1)) * depth / 2 * rng.uniform(0.6, 0.95)
        local = Vector((rng.uniform(-length, length) / 2, side, -0.02))
        lump.transform(scale=(size * 1.3, size, size * 0.7))
        lump.transform(_turned(local, turn) + Vector((x, y, z)), (0, 0, turn))
        base = vary(rng.choice(LIFE), rng, 0.1)
        model.add(group, lump, "coral", paints.organic(scale(base, 0.7), base, seed,
                                                       frequency=9.0, variation=0.3, height=0.2))


def sprig(rng, size, base=None):
    """A tuft of coral: a few curved branches, their tips glowing."""
    base = base or rng.choice((colors.CORAL_PINK, colors.CORAL_ORANGE, colors.CORAL_PURPLE))
    branches, tips = Geometry(), Geometry()
    for k in range(rng.randrange(3, 6)):
        a = 2 * math.pi * k / 5 + rng.uniform(-0.4, 0.4)
        lean = rng.uniform(0.15, 0.5)
        reach = rng.uniform(0.6, 1.0)
        points = [Vector((math.cos(a) * lean * t * t, math.sin(a) * lean * t * t, t * reach))
                  for t in (0.0, 0.5, 1.0)]
        branches.extend(sweep.tube(points, [0.07, 0.055, 0.04], sides=5))
        tips.extend(shapes.octahedron(0.05).transform(points[-1]))
    branches.transform(scale=size)
    tips.transform(scale=size)
    paint = paints.organic(scale(base, 0.75), scale(vary(base, rng, 0.1), 1.6),
                           rng.randrange(99), height=size)
    return [(branches, "coral", paint), (tips, "glow_pink", colors.GLOW_PINK)]


def _turned(local, turn):
    c, s = math.cos(turn), math.sin(turn)
    return Vector((local.x * c - local.y * s, local.x * s + local.y * c, local.z))
