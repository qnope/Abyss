"""Corals: branching staghorns, flat sea fans and rounded brain corals."""

import math

from mathutils import Matrix, Vector

from catalog import colors, paints
from workshop import noise, shapes, sweep
from workshop.colors import scale, vary
from workshop.geometry import Geometry


def staghorn(rng, size, base=None):
    base = base or rng.choice((colors.CORAL_PINK, colors.CORAL_ORANGE, colors.CORAL_PURPLE))
    geometry = Geometry()
    for _ in range(3):
        tilt = Vector((rng.uniform(-0.6, 0.6), rng.uniform(-0.6, 0.6), 1)).normalized()
        _branch(geometry, rng, Vector((rng.uniform(-0.08, 0.08), rng.uniform(-0.08, 0.08), -0.03)),
                tilt, 0.36, 0.11, 3)
    geometry.transform(scale=size)
    tip = scale(vary(base, rng, 0.1), 1.7)
    return [(geometry, "coral", paints.organic(scale(base, 0.8), tip, rng.randrange(99),
                                               height=0.7 * size))]


def _branch(geometry, rng, start, direction, length, radius, depth):
    points, radii = [start], [radius]
    heading = direction.copy()
    for k in range(1, 4):
        heading = (heading + Vector((rng.uniform(-0.25, 0.25), rng.uniform(-0.25, 0.25), 0.2))).normalized()
        points.append(points[-1] + heading * length / 3)
        radii.append(radius * (1 - 0.18 * k))
    geometry.extend(sweep.tube(points, radii, sides=5 if depth > 2 else 4, cap=depth == 1))
    if depth > 1:
        for _ in range(2):
            turn = Matrix.Rotation(rng.uniform(0.35, 0.7), 3, Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), 0)).normalized())
            _branch(geometry, rng, points[-1], (turn @ heading).normalized(), length * 0.7,
                    radii[-1] * 0.95, depth - 1)


def fan(rng, size):
    """A gorgonian: a lace of thin branches in one bent plane."""
    base = rng.choice((colors.CORAL_PURPLE, colors.CORAL_ORANGE, colors.CORAL_DEEP))
    geometry = Geometry()
    stack = [(Vector((0, 0, -0.02)), Vector((0, 0, 1)), 0.4, 0.028, 3)]
    while stack:
        start, heading, length, radius, depth = stack.pop()
        end = start + heading * length
        bend = Vector((0, 0.04 * (end.x ** 2) * 6, 0))
        geometry.extend(sweep.tube([start, start.lerp(end, 0.5) + bend * 0.5, end + bend],
                                   [radius, radius * 0.85, radius * 0.7], sides=4, cap=depth == 0))
        if depth:
            for side in (-1, 1):
                a = side * rng.uniform(0.3, 0.6)
                turned = Matrix.Rotation(a, 3, Vector((0, 1, 0))) @ heading
                stack.append((end + bend, turned, length * 0.75, radius * 0.75, depth - 1))
    geometry.transform(scale=size)
    tip = scale(vary(base, rng, 0.1), 1.6)
    return [(geometry, "coral", paints.organic(scale(base, 0.8), tip, rng.randrange(99),
                                               height=0.8 * size))]


def brain(rng, size):
    """A rounded head furrowed by meandering grooves."""
    seed = rng.randrange(1000)
    head = shapes.sphere(1.0, subdivisions=3 if size > 0.3 else 2)

    def groove(p):
        wave = math.sin(9 * p.x + 4 * noise.value(p * 2, seed)) * math.sin(9 * p.y + 4 * noise.value(p * 2, seed + 1))
        return p.normalized() * 0.09 * abs(wave)

    head.displace(groove)
    shapes.flatten_below(head, -0.2, 0.1)
    head.transform((0, 0, 0.1 * size), scale=(size, size, size * 0.55))
    base = vary(rng.choice((colors.BRAIN_TAN, colors.BRAIN_ROSE, colors.BRAIN_OLIVE)), rng)

    def paint(p, normal):
        q = p / size
        wave = abs(math.sin(9 * q.x + 4 * noise.value(q * 2, seed)) * math.sin(9 * q.y + 4 * noise.value(q * 2, seed + 1)))
        return scale(base, 0.55 + 0.7 * wave)
    return [(head, "coral", paint)]
