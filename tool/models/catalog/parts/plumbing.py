"""Pipes and cables: runs of tube along a path, with bolted flanges and
clamps along long pipes."""

import math

from mathutils import Vector

from catalog.paints import machined
from workshop import shapes, sweep


def pipe(atlas, points, radius, colour, flanges=2, seed=0, sides=8):
    """A pipe along [points], [flanges] flanges spread along it."""
    points = [Vector(p) for p in points]
    body = sweep.tube(points, [radius] * len(points), sides=sides, cap=False)
    body.sharp_angle = math.radians(50)
    parts = [(body, "hull", machined(colour, seed, soot=0.25), atlas.tiled("weathered", 0.6)(body))]
    lengths = [0.0]
    for a, b in zip(points, points[1:]):
        lengths.append(lengths[-1] + (b - a).length)
    for k in range(flanges):
        at = lengths[-1] * (k + 0.5) / flanges
        i = max(j for j in range(len(points) - 1) if lengths[j] <= at)
        t = (at - lengths[i]) / max(lengths[i + 1] - lengths[i], 1e-9)
        centre = points[i].lerp(points[i + 1], t)
        tangent = (points[i + 1] - points[i]).normalized()
        flange = shapes.cylinder(radius * 1.45, radius * 0.7, sides=sides, smooth=False)
        flange.transform((0, 0, -radius * 0.35))
        flange.apply(tangent.to_track_quat("Z", "Y").to_matrix().to_4x4())
        flange.transform(centre)
        parts.append((flange, "hull", machined(colour, seed + 1, soot=0.1),
                       atlas.fit("bolt")(flange)))
    return parts


def cable(points, radius, colour):
    """A thin, sagging cable: four sides, no flange, no texture."""
    return [(sweep.tube([Vector(p) for p in points], [radius] * len(points), sides=4, cap=False),
             "hull", colour, None)]
