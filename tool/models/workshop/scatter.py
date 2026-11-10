"""Seeded scatter: points apart from one another, only where they are allowed."""

import math


def scatter(rng, sample, count, spacing, allowed=None, taken=(), tries=200):
    """Up to [count] points drawn by [sample](rng), each at least [spacing]
    from the others and from the points [taken], and each [allowed] (any when
    it is None). Gives up after [tries] misses in a row, so a crowded area gets
    fewer points. The same [rng] state gives the same points."""
    points, others = [], list(taken)
    misses = 0
    while len(points) < count and misses < tries:
        point = sample(rng)
        if (allowed is None or allowed(point)) and all(
                math.dist(point, other) >= spacing for other in others):
            points.append(point)
            others.append(point)
            misses = 0
        else:
            misses += 1
    return points
