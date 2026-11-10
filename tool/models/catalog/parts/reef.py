"""The reef taking hold of a building: coral, sponges, anemones and algae
gathered at its foot and on its ledges, from the island's decor makers."""

import math

from mathutils import Vector

from catalog import paints
from catalog.decor import algae, corals, creatures, sponges
from catalog.parts import dress, place
from workshop import sweep
from workshop.builder import painted
from workshop.colors import mix
from workshop.scatter import scatter

# (maker, weight, size range): what grows on a colony building.
GROWTH = (
    (corals.staghorn, 2.0, (0.4, 0.7)), (corals.brain, 1.2, (0.1, 0.17)),
    (sponges.tubes, 1.5, (0.32, 0.5)), (sponges.ball, 1.5, (0.22, 0.36)),
    (algae.grass, 2.0, (0.22, 0.36)), (creatures.anemone, 2.0, (0.45, 0.7)),
    (corals.fan, 0.8, (0.35, 0.5)), (algae.kelp, 0.8, (0.5, 0.8)),
)
SMALL = tuple((m, w, (lo * 0.6, hi * 0.6)) for m, w, (lo, hi) in GROWTH if m is not algae.kelp)
# A cluster: a massive heart, small life packed around it.
HEARTS = ((corals.brain, 2.0, (0.15, 0.24)), (sponges.tubes, 2.0, (0.4, 0.58)),
          (corals.staghorn, 1.0, (0.5, 0.7)), (corals.fan, 1.0, (0.5, 0.7)))
COMPANIONS = ((creatures.anemone, 2.5, (0.4, 0.6)), (algae.grass, 2.0, (0.2, 0.32)),
              (sponges.ball, 1.5, (0.2, 0.32)), (corals.brain, 1.0, (0.08, 0.13)),
              (creatures.scallop, 1.0, (0.06, 0.09)), (creatures.sea_star, 0.8, (0.06, 0.09)))


def choose(rng, kinds):
    pick = rng.uniform(0, sum(weight for _, weight, _ in kinds))
    for maker, weight, (low, high) in kinds:
        pick -= weight
        if pick <= 0:
            return maker, rng.uniform(low, high)
    return kinds[-1][0], kinds[-1][2][1]


def grow(target, rng, atlas, spots, kinds=GROWTH):
    """A growth of [kinds] at each (x, y, z) of [spots], turned at random."""
    for x, y, z in spots:
        maker, size = choose(rng, kinds)
        place(target, dress(maker(rng, size), atlas), (x, y, z), (0, 0, rng.uniform(0, 6.28)))


def cluster(target, rng, atlas, at, size=1.0, companions=4, hearts=HEARTS):
    """A heart of [hearts] at [at] (x, y, z), [companions] small things
    packed around it, all scaled by [size]."""
    x, y, z = at
    maker, scale = choose(rng, hearts)
    place(target, dress(maker(rng, scale * size), atlas), at, (0, 0, rng.uniform(0, 6.28)))
    for k in range(companions):
        a = rng.uniform(0, 2 * math.pi)
        d = rng.uniform(0.12, 0.26) * size
        maker, scale = choose(rng, COMPANIONS)
        place(target, dress(maker(rng, scale * size), atlas),
              (x + d * math.cos(a), y + d * math.sin(a), z - 0.005), (0, 0, rng.uniform(0, 6.28)))


def around(rng, inner, outer, count, spacing, arcs=((0, 360),), z=0.0, taken=()):
    """Up to [count] spots between the radii [inner] and [outer], within the
    [arcs] (degrees, counter-clockwise from +x), [spacing] apart."""
    def sample(r):
        start, end = r.choice(arcs)
        a = math.radians(r.uniform(start, end))
        d = math.sqrt(r.uniform(inner ** 2, outer ** 2))
        return (d * math.cos(a), d * math.sin(a))
    return [(x, y, z) for x, y in scatter(rng, sample, count, spacing, taken=taken, tries=600)]



def thorn(atlas, rng, length, radius, out, colour, tip):
    """A coral thorn growing along [out] (a vector, rising some), curling
    up, from [colour] at its foot to [tip]: a defence of living coral, as a
    part painted and mapped in its own frame, its foot at the origin."""
    out = Vector(out).normalized()
    bend = rng.uniform(0.15, 0.35)
    points = [out * length * t + Vector((0, 0, bend * length * t * t)) for t in (0, 0.3, 0.6, 1.0)]
    body = sweep.tube(points, [radius, radius * 0.75, radius * 0.45, radius * 0.15], sides=5)
    mottle = paints.organic(colour, colour, rng.randrange(99), height=1.0)

    def paint(p, normal):
        return mix(mottle(p, normal), tip, (p.length / length) ** 1.5)
    return [(body, "reef", painted(body, paint), atlas.tiled("coral", 0.35)(body))]
