"""How a backdrop model is laid out: its pieces, each a node of its own that
the game repeats round the map, side by side here for review.

    Edge1, Edge2   a straight piece of rim 2 long along x, the slab's edge on
                   z = 0 (Godot), the map behind it (-z) and the sea floor
                   falling away outward (+z, the front); turn it by quarter
                   turns for the other sides. Its two ends are the bare
                   section, so any pieces meet.
    Corner         the quarter round the map's corner, which stands at the
                   origin: it joins an edge to the one a quarter turn on, the
                   game turns it to each corner.
    <far pieces>   silhouettes (a kelp forest, a skeleton, spires): a few cells
                   across, standing on y = 0, for the game to place beyond the
                   rim."""

import random

from catalog.backdrop import rim, shelf
from catalog.backdrop.specs import Spec

GAP = 3.0


def lay(model, spec: Spec):
    """Builds the pieces of [spec] into [model]."""
    rng = model.rng
    paint = rim.paint(spec.palette, spec.seed)
    for k in (1, 2):
        piece = model.piece(f"Edge{k}", ((k - 2) * GAP - GAP / 2, 0.0, 0.0))
        piece.add(rim.edge(spec.seed + k), "rock", paint)
        shelf.dress(piece, rng, spec.kinds, spec.count)
    piece = model.piece("Corner", (GAP * 1.5, 0.0, 0.0))
    piece.add(rim.corner(spec.seed + 9), "rock", paint)
    for k, (name, make, args) in enumerate(spec.far):
        make(model.piece(name, (k * 8.0 - 4.0, -9.0, 0.0)), random.Random(spec.seed + 20 + k), **args)
