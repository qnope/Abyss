"""The sea floor's tiles. A tile of the atlas is one cell of the map seen
from above (s to the right, t up, as the tile's x and y). Each fades to the
same plain shade on its borders, so that any two tiles meet without a seam,
turned by any quarter: grain and ripples inside, each tile from its own
seed. All near white: the vertex colours give the hue."""

import numpy

from workshop.atlas import Atlas, Tile

GRID = 4
INSET = 0.14  # the share of a cell, from its border, where a tile fades to plain


def _inset(canvas):
    """1 inside the cell, 0 on its border, easing in over [INSET]."""
    edge = numpy.minimum(numpy.minimum(canvas.s, 1 - canvas.s), numpy.minimum(canvas.t, 1 - canvas.t))
    t = numpy.clip(edge / INSET, 0, 1)
    return t * t * (3 - 2 * t)


def base(canvas, look):
    """The grain of a tile: ripples and fine pores, faded on its border."""
    i, j = look["ripple"]
    warp = 1.2 * canvas.fbm(2, octaves=2, seed=1)
    ripples = numpy.sin(2 * numpy.pi * (i * (canvas.s - 0.5) + j * (canvas.t - 0.5)) + warp)
    grain = canvas.noise(40, seed=2) * 0.5 + canvas.noise(90, seed=3) * 0.5
    pits = canvas.pits(26, radius=0.28, seed=4)
    return 0.86 + _inset(canvas) * (look["ripple_depth"] * ripples + 0.05 * grain - 0.1 * pits)


def overlay(canvas, look, variant):
    """What a variant adds inside its cell: [look]'s kind of detail."""
    mask = _inset(canvas)
    kind = look["detail"]
    if kind == "caustics":  # the net of light the sun throws on sunlit sand
        lines = canvas.cracks(5 + variant, width=0.22, seed=5) ** 1.5
        return mask * (0.13 * lines - 0.03)
    if kind == "flecks":  # silt with pale specks of marine snow
        flecks = (canvas.noise(60, seed=6) > 0.55).astype(float)
        hollows = canvas.pits(4 + variant, radius=0.45, seed=7)
        return mask * (0.1 * flecks - 0.14 * hollows)
    cracks = canvas.cracks(4 + variant, width=0.05, seed=8)  # ash crazed like old basalt
    dust = numpy.clip(canvas.fbm(3, seed=9) * 0.5 + 0.1, 0, 0.25)
    return mask * (0.12 * dust - 0.3 * cracks)


def painter(look, variant, hidden=False):
    """The painter of lit variant [variant], or of a tile under the fog:
    only what is shared, dimmer."""
    def paint(canvas):
        shade = base(canvas, look)
        if hidden:
            return numpy.clip(shade * 0.9, 0, 1)
        return numpy.clip(shade + overlay(canvas, look, variant), 0, 1)
    return paint


def atlas_of(look):
    """The 512 px atlas of a level: three lit cells of 256 px, two cells
    under the fog and the white tile."""
    tiles = {f"lit{k + 1}": Tile(((k % 2) * 2, (k // 2) * 2, 2, 2), painter(look, k)) for k in range(3)}
    tiles.update({f"fog{k + 1}": Tile((2 + k, 2, 1, 1), painter(look, k, True)) for k in range(2)})
    tiles["plain"] = Tile((2, 3, 1, 1), lambda canvas: numpy.ones((canvas.height, canvas.width)))
    return Atlas(512, GRID, tiles, seed=look["seed"])
