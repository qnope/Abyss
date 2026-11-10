"""The deck: 12 x 12 cells of stone slabs and metal plates, a metal ring
around the headquarters, more wear toward the edges, a curb around it all."""

from catalog import colors, paints
from catalog.base_island import layout, tiles
from catalog.base_island.layout import HALF, SIZE, plan
from workshop import shapes
from workshop import noise
from workshop.colors import scale, vary

GROUP = "Island"


def deck(model):
    rng = model.rng
    for i in range(SIZE):
        for j in range(SIZE):
            u, v = i + 0.5, j + 0.5
            if layout.in_bed(u, v):
                continue
            x, y = plan(u, v)
            hidden = layout.on_pad(x, y, -0.1)
            seed = i * SIZE + j
            if not hidden and (_near_headquarters(u, v) or rng.random() < 0.07):
                _metal(model, rng, x, y, seed)
            else:
                _stone(model, rng, x, y, seed, hidden)
    _curb(model)


def _stone(model, rng, x, y, seed, hidden):
    if hidden:
        slab = shapes.box((tiles.SIDE, tiles.SIDE, 0.06), bottom=False).transform((x, y, -0.06))
        model.add(GROUP, slab, "stone", colors.STONE_DARK)
        return
    edge = max(abs(x), abs(y)) / HALF
    roll = rng.random()
    wear = 0.05 + 0.3 * edge ** 3
    family = rng.random()
    base = colors.STONE if family < 0.55 else colors.STONE_DARK if family < 0.8 else colors.STONE_GREY
    base = scale(vary(base, rng, 0.1), 1 + 0.14 * noise.fbm((x * 0.3, y * 0.3), 5))
    turn = rng.choice((0, 1.5708))
    if hidden or roll > 0.45 + wear:
        pieces = tiles.split(1 if hidden or roll > 0.72 else rng.choice((2, 2, 2, 2, 4)), rng)
        grime = None
    elif roll > 0.45:
        chips = rng.sample(range(4), rng.choice((1, 1, 2)))
        pieces = [(tiles.slab(tiles.SIDE, tiles.SIDE, chips=chips), 0.0, 0.0)]
        base, grime = vary(colors.STONE_WORN, rng, 0.08), (colors.SAND, 0.5)
    else:
        pieces, grime = tiles.cracked(rng), (colors.SAND, 0.3)
    for geometry, dx, dy in pieces:
        sink = -rng.uniform(0.0, 0.012) - (0.012 if grime else 0.0)
        tilt = (rng.uniform(-0.01, 0.01), rng.uniform(-0.01, 0.01), turn) if grime else (0, 0, turn)
        geometry.transform(rotation=tilt).transform((x + dx, y + dy, sink))
        model.add(GROUP, geometry, "stone", paints.worked(vary(base, rng, 0.05), seed, grime=grime))


def _metal(model, rng, x, y, seed):
    kind = rng.choice(("rivets", "rivets", "ribs", "hatch", "vent"))
    turn = rng.choice((0, 1.5708))
    paint = paints.worked(vary(colors.METAL, rng, 0.08), seed, mottle=0.08, edge=1.6,
                          grime=(colors.RUST, 0.25))
    if kind == "vent":
        model.add(GROUP, tiles.vent_frame().transform((x, y, 0), (0, 0, turn)), "metal", paint)
        model.add(GROUP, tiles.vent_light().transform((x, y, 0)), "glow", colors.GLOW_CYAN)
        return
    model.add(GROUP, tiles.metal_plate().transform((x, y, 0)), "metal", paint)
    extra = {"rivets": tiles.rivets, "ribs": tiles.ribs, "hatch": tiles.hatch}[kind]()
    dark = paints.worked(vary(colors.METAL_DARK, rng, 0.08), seed + 1, edge=1.8)
    model.add(GROUP, extra.transform((x, y, 0), (0, 0, turn)), "metal", dark)


def _near_headquarters(u, v):
    hq = next(s for s in layout.SLOTS if s.building == "headquarters")
    reach = hq.footprint / 2 + 1.0
    return abs(u - hq.u) < reach and abs(v - hq.v) < reach


def _curb(model):
    """Low kerbstones along the deck's edge, between the deck and the rim."""
    rng = model.rng
    for side in range(4):
        for k in range(SIZE):
            t = -HALF + 0.5 + k
            length = 0.96 - rng.uniform(0, 0.04)
            block = shapes.box((length, 0.16, 0.12), bevel=0.02, bottom=False)
            x, y = (HALF + 0.04, t) if side % 2 == 0 else (t, HALF + 0.04)
            if side >= 2:
                x, y = -x, -y
            turn = 1.5708 if side % 2 == 0 else 0
            block.transform((0, 0, -0.1 + rng.uniform(-0.01, 0.01))).transform((x, y, 0), (0, 0, turn))
            model.add(GROUP, block, "stone", paints.worked(vary(colors.STONE_DARK, rng, 0.1), k))
