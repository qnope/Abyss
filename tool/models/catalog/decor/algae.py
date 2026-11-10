"""Algae: tall kelp with leaves and floats, and tufts of sea grass."""

import math

from mathutils import Vector

from catalog import colors, paints
from workshop import shapes, sweep
from workshop.colors import mix, scale, vary


def kelp(rng, height):
    """A stem swaying up [height], leaves along it, a float at each leaf."""
    phase = rng.uniform(0, 6.28)
    points = [Vector((0.06 * math.sin(phase + t * 4), 0.06 * math.cos(phase + t * 3), t * height))
              for t in (k / 7 for k in range(8))]
    stem = sweep.tube(points, [0.035 - 0.003 * k for k in range(8)], sides=4)
    leaves = []
    floats = []
    for k in range(2, 8):
        a = phase + k * 2.4
        out = Vector((math.cos(a), math.sin(a), 0.35)).normalized()
        start = points[k]
        length = rng.uniform(0.3, 0.5) * min(1.0, height)
        path = [start + out * length * t + Vector((0, 0, -0.12 * t * t)) for t in (0, 0.35, 0.7, 1)]
        side = Vector((-out.y, out.x, 0))
        leaves.append(sweep.ribbon(path, [0.03, 0.14, 0.12, 0.015], [side] * 4))
        floats.append(shapes.sphere(0.03, 1).transform(start + out * 0.03))
    base = vary(colors.KELP, rng, 0.12)
    tip = mix(base, colors.SPONGE_YELLOW, 0.35)
    parts = [(stem, "algae", paints.organic(scale(base, 0.6), base, rng.randrange(99)))]
    paint = paints.organic(scale(base, 0.7), tip, rng.randrange(99), variation=0.25)
    parts += [(leaf, "algae", paint) for leaf in leaves]
    parts += [(bulb, "algae", tip) for bulb in floats]
    return parts


def grass(rng, height):
    """A tuft of thin blades."""
    parts = []
    base = vary(rng.choice((colors.KELP, colors.ALGAE_TEAL)), rng, 0.15)
    for k in range(rng.randrange(5, 9)):
        a = rng.uniform(0, 2 * math.pi)
        lean = Vector((math.cos(a), math.sin(a), 0)) * rng.uniform(0.1, 0.35)
        h = height * rng.uniform(0.6, 1.0)
        path = [Vector((math.cos(a) * 0.03, math.sin(a) * 0.03, -0.02)) + lean * t * t * h +
                Vector((0, 0, t * h)) for t in (0, 0.33, 0.66, 1)]
        side = Vector((-math.sin(a), math.cos(a), 0))
        blade = sweep.ribbon(path, [0.035, 0.03, 0.02, 0.004], [side] * 4)
        parts.append((blade, "algae", paints.organic(scale(base, 0.55), mix(base, colors.SPONGE_YELLOW, 0.3), k)))
    return parts
