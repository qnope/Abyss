"""Sponges: clusters of open tubes, and round puffy balls."""

import math

from catalog import colors, paints
from workshop import noise, shapes, sweep
from workshop.colors import scale, vary


def tubes(rng, size):
    base = vary(rng.choice((colors.SPONGE_YELLOW, colors.SPONGE_ORANGE, colors.CORAL_PURPLE)), rng)
    parts = []
    for k in range(rng.randrange(2, 5)):
        h = rng.uniform(0.35, 1.0)
        r = rng.uniform(0.09, 0.14)
        wall = 0.025
        profile = [(r * 0.8, -0.03), (r, h * 0.3), (r * 1.15, h * 0.85), (r * 1.25, h),
                   (r * 1.25 - wall, h), (r * 1.1 - wall, h * 0.8), (0.0, h * 0.55)]
        tube = sweep.lathe(profile, sides=10)
        a, d = rng.uniform(0, 2 * math.pi), (0.0 if k == 0 else rng.uniform(0.15, 0.24))
        tube.transform((math.cos(a) * d, math.sin(a) * d, 0), (rng.uniform(-0.15, 0.15),
                                                                rng.uniform(-0.15, 0.15), 0))
        tube.transform(scale=size)
        parts.append((tube, "coral", _pored(scale(base, 0.7), base, rng.randrange(99), size)))
    return parts


def ball(rng, size):
    """An encrusting sponge: a lumpy cushion spread over the rock."""
    seed = rng.randrange(1000)
    puff = shapes.sphere(1.0, subdivisions=2)
    puff.displace(lambda p: p.normalized() * 0.28 * noise.fbm(p * 1.8, seed))
    shapes.flatten_below(puff, -0.2, 0.15)
    puff.transform((0, 0, 0.08 * size), scale=(size * 0.6, size * 0.5, size * 0.3))
    base = vary(rng.choice((colors.CORAL_PURPLE, colors.SPONGE_ORANGE, colors.ANEMONE)), rng)
    return [(puff, "coral", _pored(scale(base, 0.6), base, seed, size))]


def _pored(low, high, seed, size):
    organic = paints.organic(low, high, seed, frequency=6 / size)

    def paint(p, normal):
        color = organic(p.copy() / size if size else p, normal)
        pore = noise.cracks(p * 7 / size, seed, 1.0, 0.3)
        return scale(color, 1 - 0.45 * pore)
    return paint
