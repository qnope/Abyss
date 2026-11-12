"""What grows and lies on the rim's shelf: the decor makers of catalog/decor,
scattered between the slab's edge and the shelf's end, kept low."""

import math

from catalog.backdrop import rim
from catalog.parts.reef import choose
from workshop.scatter import scatter


def height_at(out):
    """The shelf's height at [out] from the slab's edge."""
    (o0, z0), (o1, z1) = next(pair for pair in zip(rim.SECTION, rim.SECTION[1:]) if pair[1][0] >= out)
    return z0 + (z1 - z0) * (out - o0) / (o1 - o0)


def dress(piece, rng, kinds, count, spacing=0.5, span=0.85, near=0.4):
    """Up to [count] things of [kinds] ((maker, weight, size range) as in
    parts.reef) on the shelf of a straight piece, [spacing] apart, within
    [span] of its middle along the rim."""
    def sample(r):
        return (r.uniform(-span, span), r.uniform(near, rim.SHELF - 0.1))

    for x, out in scatter(rng, sample, count, spacing, tries=300):
        maker, size = choose(rng, kinds)
        for geometry, material, paint in maker(rng, size):
            geometry.transform((x, -out, height_at(out) - 0.01), (0, 0, rng.uniform(0, 2 * math.pi)))
            piece.add(geometry, material, paint)
