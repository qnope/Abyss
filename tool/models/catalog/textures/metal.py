"""The machined hulls' tiles: plates bolted at their edges, straps of
rivets, a seamless grime for large or bent surfaces, louvred vents, tread
plates and worn hazard stripes."""

import numpy

from catalog.textures.lights import CYAN
from catalog.textures.marks import blend, drips, edge_distance, grime, rivets, seam, tint
from workshop.colors import linear

RUST = numpy.array(linear("#c27a52"))
SOOT = numpy.array(linear("#5a5650"))
HAZARD = numpy.array(linear("#f0b43c"))


def _metal(canvas, seed=0):
    """Bare plate: mottled, a fine grain and a few bright scratches."""
    shade = 0.9 + 0.05 * canvas.fbm(4, octaves=4, seed=seed) + 0.025 * canvas.noise(28, seed + 1)
    scratches = canvas.cracks(6, width=0.025, seed=seed + 2) * (canvas.noise(5, seed + 3) > 0.25)
    return shade * (1 + 0.14 * scratches)


def _row(start, end, spacing):
    count = max(1, round((end - start) / spacing))
    return [start + (end - start) * (k + 0.5) / count for k in range(count)]


def plate(canvas, across=1, up=1, spacing=22.0, rust=0.55):
    """[across] x [up] plates in the tile, each bolted all round its edge,
    grimy toward the bottom, rust running from its top rivets."""
    w, h = canvas.width / across, canvas.height / up
    local_x, local_y = canvas.x % w, canvas.y % h
    distance = numpy.minimum(numpy.minimum(local_x, w - local_x), numpy.minimum(local_y, h - local_y))
    shade = _metal(canvas) * seam(distance) * grime(canvas, 0.3)
    points, sources = [], []
    for i in range(across):
        for j in range(up):
            x0, y0, inset = i * w, j * h, 6.5
            xs, ys = _row(x0 + inset, x0 + w - inset, spacing), _row(y0 + inset, y0 + h - inset, spacing)
            top = [(x, y0 + h - inset) for x in xs]
            points += top + [(x, y0 + inset) for x in xs]
            points += [(x0 + inset, y) for y in ys] + [(x0 + w - inset, y) for y in ys]
            sources += top[1::2]
    shade = shade * rivets(canvas, points, 2.4)
    stain = drips(canvas, sources, canvas.height * 0.45 / up, 2.2, seed=5)
    stain = stain * numpy.clip(0.4 + canvas.noise(5, seed=6), 0, 1) * rust
    return blend(tint(shade, (1, 1, 1)), RUST * shade[..., None], stain)


def strap(canvas):
    """A riveted band: a seam above and below, one row of rivets."""
    distance = numpy.minimum(canvas.y, canvas.height - canvas.y)
    shade = _metal(canvas, seed=4) * seam(distance, 2.5, 6.0) * grime(canvas, 0.15)
    middle = canvas.height / 2
    points = [(x, middle) for x in _row(0, canvas.width, canvas.height * 0.8)]
    return shade * rivets(canvas, points, canvas.height * 0.13)


def weathered(canvas):
    """Seamless grime: stains, soot and rust blooms over bare metal."""
    shade = _metal(canvas, seed=8) * (0.92 + 0.08 * canvas.fbm(2, octaves=3, seed=9))
    soot = numpy.clip(canvas.fbm(3, octaves=4, seed=10) * 1.6 - 0.2, 0, 1) * 0.5
    rust = numpy.clip(canvas.fbm(5, octaves=3, seed=11) * 2.2 - 0.9, 0, 1)
    pits = canvas.pits(14, radius=0.18, seed=12) * rust
    colour = blend(tint(shade, (1, 1, 1)), SOOT * shade[..., None], soot)
    colour = blend(colour, RUST * shade[..., None], rust * 0.7)
    return colour * (1 - 0.4 * pits[..., None])


def vent(canvas, slats=7):
    """Louvres: dark gaps under lit slat edges, in a frame."""
    frame = seam(edge_distance(canvas), 2.0, 4.0)
    inside = canvas.box(8, 8, canvas.width - 8, canvas.height - 8)
    phase = ((canvas.y - 8) / (canvas.height - 16) * slats) % 1.0
    slat = numpy.where(phase < 0.35, 0.12 + 0.5 * phase, 0.75 + 0.35 * (phase > 0.85))
    shade = _metal(canvas, seed=13) * frame
    return shade * (1 - inside) + inside * slat * (0.9 + 0.1 * canvas.noise(9, seed=14))


def tread(canvas, frequency=10):
    """A tread plate: raised diamonds, lit on one flank, worn in the middle."""
    a = (canvas.s + canvas.t) * frequency
    b = (canvas.s - canvas.t) * frequency
    ridge = numpy.where((numpy.floor(a) + numpy.floor(b)) % 2 == 0,
                        numpy.abs((a % 1) - 0.5), numpy.abs((b % 1) - 0.5))
    bump = numpy.clip(1 - ridge * 6, 0, 1)
    shade = _metal(canvas, seed=15) * (0.85 + 0.3 * bump) * grime(canvas, 0.2, seed=16)
    return shade * seam(edge_distance(canvas), 1.5, 3.0)


def hazard(canvas, stripes=4):
    """Worn yellow and black stripes, chipped down to the metal."""
    band = ((canvas.s + canvas.t) * stripes) % 1.0 < 0.5
    chips = numpy.clip(canvas.fbm(6, octaves=4, seed=17) * 2.5 - 0.8, 0, 1)
    paint = numpy.where(band[..., None], HAZARD, numpy.array((0.05, 0.05, 0.05)))
    bare = tint(_metal(canvas, seed=18), (0.8, 0.8, 0.8))
    colour = blend(paint * (0.9 + 0.1 * canvas.noise(12, 19))[..., None], bare, chips)
    return colour * seam(edge_distance(canvas), 2.0, 3.0)[..., None]


def bolt(canvas):
    """One bolt at the heart of a strip of metal: a flange's segment."""
    distance = numpy.minimum(canvas.y, canvas.height - canvas.y)
    shade = _metal(canvas, seed=20) * seam(distance, 2.0, 4.0)
    centre = [(canvas.width / 2, canvas.height / 2)]
    return shade * rivets(canvas, centre, min(canvas.width, canvas.height) * 0.16)


def door(canvas):
    """Two riveted leaves over a band of hazard stripes: a hatch's door."""
    leaves = plate(canvas, across=2, spacing=18.0, rust=0.3)
    band = canvas.y < canvas.height * 0.16
    stripes = hazard(canvas, stripes=6)
    return numpy.where(band[..., None], stripes, leaves)


def emblem(canvas):
    """The colony's badge: a cyan trident rising from waves, in a ring of
    rivets on a navy disc, worn at the edges."""
    cx, cy, r = canvas.width / 2, canvas.height / 2, canvas.width / 2
    navy = numpy.array(linear("#22324d"))
    colour = numpy.broadcast_to(navy, canvas.x.shape + (3,)).copy()
    ring = numpy.clip(1 - numpy.abs(numpy.hypot(canvas.x - cx, canvas.y - cy) - r * 0.82) / 3, 0, 1)
    shaft = canvas.box(cx - 2.5, cy - r * 0.45, cx + 2.5, cy + r * 0.45)
    prongs = sum(canvas.box(cx + dx - 2.5, cy + r * 0.15, cx + dx + 2.5, cy + r * 0.52)
                 for dx in (-r * 0.28, r * 0.28))
    bar = canvas.box(cx - r * 0.3, cy + r * 0.12, cx + r * 0.3, cy + r * 0.2)
    waves = numpy.clip(1 - numpy.abs(canvas.y - (cy - r * 0.3 + 4 * numpy.sin(canvas.x / 5))) / 2, 0, 1)
    waves *= numpy.abs(canvas.x - cx) < r * 0.55
    mark = numpy.clip(ring + shaft + prongs + bar + waves, 0, 1)
    colour = blend(colour, CYAN * 0.9, mark)
    wear = numpy.clip(canvas.fbm(6, octaves=4, seed=21) * 2 - 0.7, 0, 1) * 0.5
    return blend(colour, numpy.array((0.7, 0.72, 0.75)), wear)
