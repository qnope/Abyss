"""The tiles of the six units' atlas: a 256 px square cut in 8 x 8 cells of 32
px. Light colours for the lamps (visors, lenses, nozzles), riveted plates and
straps for the armour, hazard stripes, the colony's emblem, an amber porthole, and a
seamless neoprene weave for the diving suits. Like the buildings' tiles they are
near white: the vertex colours give the hue."""

import numpy

from catalog.textures import lights, metal
from catalog.textures.lights import AMBER, CYAN, DARK, GOLD, WHITE
from catalog.textures.marks import blend
from workshop.atlas import Atlas, Tile
from workshop.colors import linear

RED = numpy.array(linear("#ff2a3c")) * 0.9
GREEN = numpy.array(linear("#4dffa0")) * 0.85
VIOLET = numpy.array(linear("#c77dff")) * 0.85


def weave(canvas):
    """A seamless neoprene: a fine diamond lattice, softly mottled."""
    a, b = (canvas.s + canvas.t) * 7, (canvas.s - canvas.t) * 7
    ridge = numpy.minimum(numpy.abs(a % 1 - 0.5), numpy.abs(b % 1 - 0.5))
    shade = 0.86 + 0.16 * numpy.clip(ridge * 3, 0, 1) + 0.05 * canvas.noise(3, seed=2)
    return (shade * (0.95 + 0.05 * canvas.noise(8, seed=3)))[..., None]


def visor(canvas):
    """A curved visor: bright at its heart, darker at its rim, a gleam."""
    d = numpy.hypot((canvas.x - canvas.width / 2) / canvas.width,
                    (canvas.y - canvas.height / 2) / canvas.height) * 2
    glow = numpy.clip(0.9 - 0.6 * d * d, 0.1, 1)[..., None]
    gleam = numpy.clip(1 - numpy.abs(canvas.s * 0.8 + canvas.t - 1.15) / 0.07, 0, 1)
    return blend(CYAN * glow, WHITE, gleam * 0.4)


UNITS = {
    "plain": Tile((0, 0, 1, 1), lights.solid((1.0, 1.0, 1.0))),
    "cyan": Tile((1, 0, 1, 1), lights.solid(CYAN)),
    "amber": Tile((2, 0, 1, 1), lights.solid(AMBER)),
    "red": Tile((3, 0, 1, 1), lights.solid(RED)),
    "green": Tile((4, 0, 1, 1), lights.solid(GREEN)),
    "gold": Tile((5, 0, 1, 1), lights.solid(GOLD)),
    "violet": Tile((6, 0, 1, 1), lights.solid(VIOLET)),
    "dark": Tile((7, 0, 1, 1), lights.solid(DARK)),
    "plate": Tile((0, 1, 2, 2), metal.plate),
    "strap": Tile((2, 1, 2, 1), metal.strap),
    "hazard": Tile((4, 1, 2, 1), metal.hazard),
    "emblem": Tile((2, 2, 2, 2), metal.emblem),
    "porthole": Tile((4, 2, 2, 2), lights.porthole(AMBER)),
    "visor": Tile((6, 1, 2, 2), visor),
    "weave": Tile((0, 3, 2, 2), weave, seamless=True),
}


def atlas(size=256, seed=0):
    """The units' atlas: every unit paints the same one."""
    return Atlas(size, 8, UNITS, seed)
