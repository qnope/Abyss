"""What hangs from the plateau: strands of algae down its sides, from the lip,
and roots from its underside, swaying into the abyss."""

import math

from mathutils import Vector

from catalog import colors, paints
from catalog.base_island import outline
from workshop import sweep
from workshop.colors import mix, scale, vary

GROUP = "Island"


def hanging(model, columns):
    rng = model.rng
    pairs = outline.perimeter()
    for index, (q, n) in enumerate(pairs):
        if rng.random() < 0.45:
            continue
        for _ in range(rng.randrange(1, 4)):
            _strand(model, rng, q, n, index, columns[index])
    for column in columns[::5]:
        if rng.random() < 0.6:
            _root(model, rng, column[-4 + rng.randrange(0, 2)])


def _strand(model, rng, q, n, seed, column):
    side = Vector((-n.y, n.x, 0))
    shift = rng.uniform(-0.15, 0.15)
    length = rng.uniform(0.4, 1.6) * (1.4 if rng.random() < 0.2 else 1.0)
    steps = 6
    points, widths, sides = [], [], []
    for k in range(steps + 1):
        t = k / steps
        z = -0.12 - length * t
        out = _wall(q, n, column, z) + 0.05 + 0.04 * math.sin(t * 5 + seed) + 0.03 * t
        p = q + n * out + side.to_2d() * shift
        points.append(Vector((p.x, p.y, z)))
        widths.append(0.07 * (1 - 0.75 * t) + 0.01)
        sides.append(side)
    base = vary(rng.choice((colors.KELP, colors.ALGAE_TEAL, colors.KELP_DARK, colors.RUST)), rng)
    paint = paints.organic(base, scale(mix(base, colors.SPONGE_YELLOW, 0.2), 1.3), seed)
    model.add(GROUP, sweep.ribbon(points, widths, sides), "algae",
              lambda p, normal: paint(Vector((p.x, p.y, -p.z / max(length, 0.1))), normal))


def _wall(q, n, column, z):
    """How far the rock stands out from the deck's edge around height z."""
    near = [p for p in column if abs(p.z - z) <= 0.35] or [min(column, key=lambda p: abs(p.z - z))]
    return max((p.to_2d() - q).dot(n) for p in near)


def _root(model, rng, top):
    length = rng.uniform(1.0, 3.2)
    lean = Vector((rng.uniform(-0.3, 0.3), rng.uniform(-0.3, 0.3), 0))
    curl = rng.uniform(0, 6.28)
    points = [top + Vector((0, 0, 0.1))]
    for k in range(1, 8):
        t = k / 7
        wiggle = Vector((math.cos(curl + t * 6), math.sin(curl + t * 6), 0)) * 0.08
        points.append(top + lean * t * length * 0.4 + wiggle + Vector((0, 0, -length * t)))
    radii = [0.05 * (1 - 0.8 * k / 7) + 0.008 for k in range(8)]
    model.add(GROUP, sweep.tube(points, radii, sides=4), "algae",
              paints.organic(colors.ROOT, scale(colors.ROOT, 0.6), rng.randrange(99)))
