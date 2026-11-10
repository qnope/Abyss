"""The island's decor, scattered by seed: a belt of rocks along the rim and
life among them, small things on the free deck cells near its edges, never
on a pad, a walkway or the rampart's band."""

import math

from mathutils import Vector

from catalog.base_island import layout, outline
from catalog.base_island.layout import HALF, RAMPART_TO
from catalog.decor import algae, corals, creatures, rocks, sponges
from workshop.scatter import scatter

GROUP = "Island"

# The heart of a cluster on the rim: (maker, weight, size range, tall).
HEROES = (
    (corals.staghorn, 3, (1.2, 1.7), True), (corals.fan, 2, (1.1, 1.5), True),
    (sponges.tubes, 2, (0.95, 1.3), True), (algae.kelp, 2.5, (1.4, 2.1), True),
    (corals.brain, 1.5, (0.38, 0.52), False),
)
# What gathers around it.
COMPANIONS = (
    (creatures.anemone, 2.5, (1.1, 1.5), False), (algae.grass, 2.5, (0.4, 0.6), False),
    (sponges.ball, 1.5, (0.35, 0.55), False), (corals.brain, 1, (0.18, 0.28), False),
    (corals.staghorn, 1.5, (0.6, 0.85), False), (creatures.scallop, 1, (0.12, 0.18), False),
    (creatures.sea_star, 1, (0.12, 0.17), False),
)
DECK_LIFE = (
    (creatures.anemone, 2, (0.7, 1.0), False), (algae.grass, 2, (0.25, 0.4), False),
    (creatures.scallop, 1.5, (0.1, 0.14), False), (creatures.sea_star, 1.5, (0.1, 0.14), False),
    (corals.brain, 1, (0.14, 0.2), False), (rocks.pebbles, 1.5, (0.2, 0.3), False),
    (corals.staghorn, 1, (0.35, 0.5), True),
)


def decor(model):
    rng = model.rng
    taken = []
    centres = scatter(rng, _rim_sample, count=34, spacing=1.2,
                      allowed=lambda p: _on_rim(p) and _room(*p) > 0.35, tries=4000)
    for x, y in centres:
        taken += _cluster(model, rng, x, y)
    rocks_spots = scatter(rng, _rim_sample, count=80, spacing=0.3, allowed=_on_rim,
                          taken=taken, tries=4000)
    for x, y in rocks_spots:
        size = rng.uniform(0.12, 0.28)
        maker = rocks.boulder if rng.random() < 0.75 else rocks.slab
        _stand(model, maker(rng, min(_room(x, y) * 0.8, size)), x, y, rng)
    gravel = scatter(rng, _rim_sample, count=110, spacing=0.16, allowed=_on_rim,
                     taken=taken + rocks_spots, tries=4000)
    for x, y in gravel:
        _stand(model, rocks.pebbles(rng, rng.uniform(0.12, 0.22), count=1), x, y, rng)
    deck = scatter(rng, lambda r: (r.uniform(-HALF, HALF), r.uniform(-HALF, HALF)), count=26,
                   spacing=0.6, allowed=_on_deck_edge, tries=4000)
    for x, y in deck:
        maker, size = _choose(rng, DECK_LIFE, _front(x, y))
        place(model, maker(rng, size), x, y, -0.01, rng)


def _cluster(model, rng, x, y):
    """A hero coral or algae among big rocks and smaller life; gives the spots."""
    room = min(1.0, _room(x, y) * 1.3)
    maker, size = _choose(rng, HEROES, _front(x, y))
    _stand(model, maker(rng, size * (0.7 + 0.3 * room)), x, y, rng)
    spots = [(x, y)]
    for k in range(rng.randrange(5, 9)):
        a, r = rng.uniform(0, 2 * math.pi), rng.uniform(0.28, 0.6)
        px, py = x + math.cos(a) * r, y + math.sin(a) * r
        if not _on_rim((px, py)) or any(math.dist((px, py), s) < 0.22 for s in spots):
            continue
        if k < 2:
            parts = rocks.boulder(rng, min(_room(px, py), rng.uniform(0.3, 0.55)))
        else:
            kind, small = _choose(rng, COMPANIONS, _front(px, py))
            parts = kind(rng, small)
        _stand(model, parts, px, py, rng)
        spots.append((px, py))
    return spots


def _stand(model, parts, x, y, rng):
    place(model, parts, x, y, outline.height_at(x, y) - 0.03, rng)


def place(model, parts, x, y, z, rng, tilt=0.12):
    """Adds the decor [parts] standing at (x, y, z), turned at random."""
    turn = (rng.uniform(-tilt, tilt), rng.uniform(-tilt, tilt), rng.uniform(0, 2 * math.pi))
    for geometry, material, paint in parts:
        geometry.transform(rotation=turn).transform((x, y, z))
        model.add(GROUP, geometry, material, _shifted(paint, Vector((x, y, z))))


def _shifted(paint, origin):
    """The decor's paints take heights from its foot: give them local points."""
    if not callable(paint):
        return paint
    return lambda p, normal: paint(p - origin, normal)


def _choose(rng, kinds, front):
    weights = [w * (1 - 0.8 * max(front, 0)) if tall else w for _, w, _, tall in kinds]
    pick = rng.random() * sum(weights)
    for (maker, _, (low, high), _), weight in zip(kinds, weights):
        pick -= weight
        if pick <= 0:
            return maker, rng.uniform(low, high)
    return kinds[-1][0], kinds[-1][2][0]


def _front(x, y):
    """1 at the deck's corner nearest the game camera (u = v = 12), -1 at the far one."""
    return (x - y) / (2 * HALF)


def _rim_sample(rng):
    return (rng.uniform(-HALF - 2.2, HALF + 2.2), rng.uniform(-HALF - 2.2, HALF + 2.2))


def _on_rim(point):
    x, y = point
    q, n, d = outline.nearest(x, y)
    return d > RAMPART_TO + 0.12 and d < outline.margin(q, n) - 0.12 and layout.free_for_decor(x, y)


def _room(x, y):
    q, n, d = outline.nearest(x, y)
    return max(0.12, min(d - RAMPART_TO - 0.05, outline.margin(q, n) - d) * 1.3)


def _on_deck_edge(point):
    x, y = point
    u, v = layout.cell(x, y)
    return (max(abs(x), abs(y)) > HALF - 1.4 and layout.free_for_decor(x, y)
            and not layout.in_bed(u, v) and max(abs(x), abs(y)) < HALF - 0.2)
