"""The production buildings' tiles, laid out beside the colony's in one atlas:
the lit greenhouse pane, the glowing algae pool and the bubbling reactor of
the algae farm, the veined rock of the coral mine (pink) and of the ore
extractor (blue), and the lights of their colour (green, blue, gold panes).
Lamp tiles are both reflected and emitted, so what is dark in them stays
dark and what is bright glows."""

import numpy

from catalog.textures import colony, lights
from catalog.textures.marks import blend, edge_distance
from workshop.atlas import Tile
from workshop.colors import linear

GREEN = numpy.array(linear("#46f08c")) * 0.85
BLUE = numpy.array(linear("#3ea6ff")) * 0.85
PINK_VEIN = numpy.array(linear("#ff4aa5")) * 0.9
DARK = numpy.array((0.02, 0.025, 0.03))
ROCK_PINK = numpy.array(linear("#2a1822"))
ROCK_BLUE = numpy.array(linear("#16202e"))


def glasshouse(canvas):
    """A greenhouse pane lit green from within: brighter low down, the
    dark fronds growing against it, a bar down the middle, a frame."""
    frame = numpy.clip((edge_distance(canvas) - 5) / 1.5, 0, 1)
    bar = numpy.clip(numpy.abs(canvas.x - canvas.width / 2) / 1.6 - 0.6, 0, 1)
    fronds = numpy.clip(canvas.fbm(5, octaves=2, seed=3) * 2.2 - 0.2, 0, 1) * (0.25 + 0.5 * canvas.t)
    glow = (1.05 - 0.4 * canvas.t) * (0.9 + 0.1 * canvas.noise(5, seed=4)) * (1 - 0.55 * fronds)
    return blend(numpy.broadcast_to(DARK, glow.shape + (3,)).copy(), GREEN * glow[..., None],
                 frame * bar)


def pool(canvas):
    """A basin of nutrient broth: a bright green, ripples, drifting mats of
    darker algae and pale bubbles."""
    ripple = 0.5 + 0.5 * numpy.sin(canvas.s * 25 + 3 * canvas.fbm(3, seed=5))
    mats = numpy.clip(canvas.fbm(4, octaves=3, seed=6) * 2.0, 0, 1)
    glow = (0.62 + 0.2 * ripple) * (1 - 0.35 * mats) + 0.5 * canvas.pits(9, 0.22, seed=7)
    return GREEN * numpy.clip(glow, 0, 1.15)[..., None]


def reactor(canvas):
    """The bioreactor's column: a glowing broth, rounder at the middle of
    each facet, trains of bubbles rising."""
    round_ = 0.55 + 0.45 * numpy.sin(numpy.pi * canvas.s)
    bubbles = canvas.pits(7, 0.3, seed=8) ** 0.6
    swirl = 0.85 + 0.15 * canvas.noise(3, seed=9)
    return GREEN * (round_ * swirl * (0.8 + 0.2 * canvas.t) + 0.7 * bubbles)[..., None]


def veins(rock, glow, seed):
    """Rock threaded by glowing veins and pockets, seamless: a lode."""
    def paint(canvas):
        shade = 1.0 + 0.5 * canvas.fbm(4, octaves=3, seed=seed)
        lines = canvas.cracks(4, width=0.16, seed=seed + 1) ** 1.6
        lines *= numpy.clip(canvas.noise(3, seed=seed + 2) + 0.55, 0, 1)
        pockets = canvas.pits(6, radius=0.2, seed=seed + 3) ** 1.4
        glowing = numpy.clip(lines * 0.9 + pockets * 0.7, 0, 1)
        return blend(rock * shade[..., None], glow, glowing)
    return paint


EXTRA = {
    "green": Tile((12, 6, 1, 1), lights.solid(GREEN)),
    "blue": Tile((13, 6, 1, 1), lights.solid(BLUE)),
    "panes_gold": Tile((14, 6, 2, 2), lights.panes(lights.GOLD, across=3, up=2, frame=4.0)),
    "veins_pink": Tile((8, 8, 4, 4), veins(ROCK_PINK, PINK_VEIN, 31), seamless=True),
    "veins_blue": Tile((12, 8, 4, 4), veins(ROCK_BLUE, BLUE, 41), seamless=True),
    "pool": Tile((8, 12, 2, 2), pool),
    "glasshouse": Tile((10, 12, 2, 2), glasshouse),
    "panes_blue": Tile((12, 12, 2, 2), lights.panes(BLUE, across=3, up=1, frame=4.0)),
    "reactor": Tile((14, 12, 2, 4), reactor),
}


def atlas(seed=0):
    """The colony's tiles and the production buildings' in one atlas."""
    return colony.atlas(EXTRA, seed=seed)

