"""The command buildings' own tiles (laboratory, barracks, and the lights and
cloth of the headquarters and the citadel), laid in the free cells of the
colony's atlas: a teal and a red light with their windows, a glowing specimen
tank, scrubbed white wall panels and a banner of cloth."""

import numpy

from catalog.textures import colony, lights
from catalog.textures.marks import blend, edge_distance, grime, rivets, seam
from workshop.atlas import Tile
from workshop.colors import linear

TEAL = numpy.array(linear("#1de9b6")) * 0.85
RED = numpy.array(linear("#ff3b4e")) * 0.85
LEVEL = 0.86  # how high the liquid stands in a tank, of the tile


def panel(canvas, across=2, up=2):
    """Scrubbed wall panels: fine seams, a screw at each corner, a little
    grime low down, no rust: a laboratory is kept clean."""
    w, h = canvas.width / across, canvas.height / up
    lx, ly = canvas.x % w, canvas.y % h
    distance = numpy.minimum(numpy.minimum(lx, w - lx), numpy.minimum(ly, h - ly))
    shade = (0.93 + 0.04 * canvas.fbm(4, octaves=3, seed=31)) * seam(distance, 1.6, 4.0)
    screws = [(i * w + dx, j * h + dy) for i in range(across) for j in range(up)
              for dx in (6, w - 6) for dy in (6, h - 6)]
    shade = shade * rivets(canvas, screws, 1.8) * grime(canvas, 0.22, seed=32)
    return shade[..., None] * numpy.ones(3)


def liquid(canvas):
    """A tank of glowing liquid: brighter low down, rising bubbles, a bright
    meniscus, and above the surface dark glass with a faint reflection."""
    below = canvas.t < LEVEL
    depth = numpy.clip((LEVEL - canvas.t) / LEVEL, 0, 1)
    glow = 0.38 + 0.3 * (1 - depth) ** 0.5 + 0.2 * canvas.fbm(3, octaves=2, seed=33)
    bubbles = canvas.pits(7, radius=0.16, seed=34) * (canvas.noise(3, seed=35) > -0.1)
    colour = TEAL * numpy.clip(glow + 0.9 * bubbles, 0, 1.2)[..., None]
    meniscus = numpy.clip(1 - numpy.abs(canvas.t - LEVEL) * canvas.height / 5, 0, 1)
    colour = blend(colour, numpy.ones(3) * 0.9, meniscus * 0.7)
    above = lights.DARK + TEAL * 0.08 * (canvas.s[..., None] * numpy.ones(3))
    out = numpy.where(below[..., None], colour, above)
    return out * numpy.clip((edge_distance(canvas) - 2) / 2, 0, 1)[..., None]


def banner(canvas):
    """Woven cloth, stitched along its border, two chevrons of the colony's
    emblem stitched darker across it, a frayed fall at the bottom."""
    weave = 0.9 + 0.06 * numpy.sin(canvas.x * 1.7) * numpy.sin(canvas.y * 1.7)
    shade = weave * (0.95 + 0.05 * canvas.fbm(5, seed=36))
    stitch = (edge_distance(canvas) > 6) & (edge_distance(canvas) < 8) & (
        (numpy.floor(canvas.x / 4) + numpy.floor(canvas.y / 4)) % 2 == 0)
    centre = numpy.abs(canvas.s - 0.5) * canvas.width
    mark = numpy.zeros_like(centre)
    for k, base in enumerate((0.58, 0.42)):
        line = canvas.t - base + centre / canvas.height * 0.9
        mark = numpy.maximum(mark, numpy.clip(1 - numpy.abs(line) * canvas.height / 7, 0, 1))
    mark *= numpy.abs(canvas.s - 0.5) < 0.38
    shade = shade * (1 - 0.5 * mark) * (1 - 0.25 * stitch)
    fall = numpy.clip((canvas.t - 0.04) / 0.1, 0, 1)
    return (shade * (0.55 + 0.45 * fall))[..., None] * numpy.ones(3)


TILES = {
    "teal": Tile((8, 7, 1, 1), lights.solid(TEAL)),
    "red": Tile((9, 7, 1, 1), lights.solid(RED)),
    "panes_teal": Tile((8, 8, 2, 2), lights.panes(TEAL, across=2, up=3)),
    "porthole_teal": Tile((10, 8, 2, 2), lights.porthole(TEAL)),
    "ribbon_teal": Tile((12, 8, 4, 1), lights.ribbon(TEAL)),
    "ribbon_red": Tile((12, 9, 4, 1), lights.ribbon(RED)),
    "liquid": Tile((8, 10, 2, 4), liquid),
    "banner": Tile((10, 10, 2, 4), banner),
    "panel": Tile((12, 10, 2, 2), panel),
    "panel_wide": Tile((12, 12, 4, 2), lambda c: panel(c, across=4, up=1)),
    "panes_red": Tile((14, 10, 2, 2), lights.panes(RED, across=2, up=2)),
}


def atlas(size=1024, seed=0):
    """The colony's atlas with the command buildings' tiles."""
    return colony.atlas(TILES, size, seed)
