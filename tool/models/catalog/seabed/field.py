"""Fields over a tile of the map that repeat every cell: the same value on
a tile's left and right edge, on its top and bottom, whatever the tile. What
two neighbours share (the sand's grain, its colour, its ripples) is drawn
from these, so that they meet without a seam; what makes a variant its own
is faded out toward the edges (envelope)."""

import math
import random

EDGE = 0.5  # half a cell


def wave(x, y, seed, octaves=3):
    """A smooth field in about [-1, 1], periodic in x and y with period 1:
    a sum of waves of whole frequencies, finer and weaker at each octave."""
    rng = random.Random(seed)
    total = norm = 0.0
    for octave in range(octaves):
        weight = 0.5 ** octave
        for _ in range(3):
            i, j = rng.randint(-2, 2) * (octave + 1), rng.randint(0, 2) * (octave + 1)
            if i == 0 and j == 0:
                i = octave + 1
            phase = rng.uniform(0, 2 * math.pi)
            total += weight * math.sin(2 * math.pi * (i * x + j * y) + phase)
            norm += weight
    return 1.6 * total / norm / 1.7


def smooth(t):
    """0 below 0, 1 above 1, an ease between."""
    t = min(max(t, 0.0), 1.0)
    return t * t * (3 - 2 * t)


def envelope(x, y, margin):
    """0 on the tile's border, 1 from [margin] inside it: what is multiplied
    by this stays out of the seams."""
    return smooth((EDGE - abs(x)) / margin) * smooth((EDGE - abs(y)) / margin)


def blob(x, y, centre, radius):
    """1 at [centre], falling smoothly to 0 at [radius] from it."""
    return smooth(1 - math.hypot(x - centre[0], y - centre[1]) / radius)
