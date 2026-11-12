"""The tiles of the buildings of the descent (descent module, pressure capsule,
volcanic kernel), laid out in the free cells of the colony's atlas: molten
rock and the colours of its fire, cooled basalt, blue lights, a painted steel
plate and a round hatch. deep_tiles() is the `extra` of colony.atlas()."""

import numpy

from catalog.textures import lights
from catalog.textures.marks import rivets, seam
from workshop.atlas import Tile
from workshop.colors import linear

LAVA = numpy.array(linear("#ff5a12")) * 0.9
MOLTEN = numpy.array(linear("#ffc33a")) * 0.95
EMBER = numpy.array(linear("#e0360f")) * 0.8
BLUE = numpy.array(linear("#3d8bff")) * 0.85
CRUST = numpy.array((0.03, 0.012, 0.01))
_STOPS = (0.0, 0.3, 0.62, 1.0)
_FIRE = numpy.array((CRUST, EMBER * 0.45, LAVA, MOLTEN))


def fire(heat):
    """The colour of molten rock at [heat] in [0, 1]: black crust, a red
    ember, orange lava, a yellow heart."""
    t = numpy.clip(heat, 0, 1)
    return numpy.stack([numpy.interp(t, _STOPS, _FIRE[:, c]) for c in range(3)], axis=-1)


def magma(canvas):
    """Seamless molten rock: dark crust plates drifting on lava, which shows
    bright in the cracks between them and in a few hot patches."""
    plates = canvas.cracks(4, width=0.34, seed=1)
    hot = canvas.fbm(3, octaves=3, seed=2)
    wander = 0.12 * canvas.fbm(9, octaves=2, seed=3)
    return fire(0.12 + 0.95 * plates + 0.3 * hot + wander - 0.2)


def basalt(canvas):
    """Seamless cooled lava: dark glassy columns cut by hairline cracks, the
    pits of trapped gas and a few pale specks."""
    shade = 0.8 + 0.12 * canvas.fbm(4, octaves=4, seed=4)
    columns = 0.12 * canvas.cells(5, seed=5)
    cracks = canvas.cracks(5, width=0.05, seed=6) * numpy.clip(canvas.noise(3, seed=7) + 0.5, 0, 1)
    pits = canvas.pits(26, radius=0.28, seed=8) ** 0.8
    shade = (shade + columns) * (1 - 0.5 * cracks) * (1 - 0.3 * pits)
    specks = (canvas.noise(44, seed=9) > 0.78).astype(float)
    return numpy.clip(shade * (1 + 0.5 * specks), 0, 1.2)[..., None]


def plates(canvas):
    """Seamless painted steel: 2 x 2 panels bolted at their edges, a fine
    grain, a few scratches and the paint worn at the seams."""
    w, h = canvas.width / 2, canvas.height / 2
    lx, ly = canvas.x % w, canvas.y % h
    distance = numpy.minimum(numpy.minimum(lx, w - lx), numpy.minimum(ly, h - ly))
    shade = 0.93 + 0.04 * canvas.fbm(5, octaves=3, seed=10) + 0.02 * canvas.noise(30, 11)
    scratch = canvas.cracks(8, width=0.03, seed=12) * (canvas.noise(5, 13) > 0.3)
    points = [(i * w + o, j * h + o2) for i in range(2) for j in range(2)
              for o in (8, w - 8) for o2 in (8, h - 8)]
    return (shade * (1 + 0.1 * scratch) * seam(distance, 1.5, 4.0) * rivets(canvas, points, 2.2))[..., None]


def hatch(canvas):
    """A round hatch seen from the front: a rimmed door, a ring of bolts, a
    wheel of three spokes at its heart."""
    cx, cy, r = canvas.width / 2, canvas.height / 2, canvas.width / 2
    d = numpy.hypot(canvas.x - cx, canvas.y - cy) / r
    angle = numpy.arctan2(canvas.y - cy, canvas.x - cx)
    rim = numpy.clip(1 - numpy.abs(d - 0.88) / 0.06, 0, 1)
    spokes = numpy.clip(1 - numpy.abs(numpy.sin(angle * 1.5)) * d * r / 4, 0, 1) * (d < 0.5)
    wheel = numpy.clip(1 - numpy.abs(d - 0.5) / 0.06, 0, 1)
    bolts = [(cx + 0.74 * r * numpy.cos(a), cy + 0.74 * r * numpy.sin(a))
             for a in numpy.linspace(0, 2 * numpy.pi, 9)[:-1]]
    shade = (0.88 + 0.06 * canvas.fbm(4, seed=14)) * (1 - 0.45 * rim) * (1 + 0.3 * (wheel + spokes))
    shade = shade * rivets(canvas, bolts, 2.6) * numpy.clip((1.02 - d) * 20, 0.25, 1)
    return numpy.clip(shade, 0, 1.2)[..., None]


def deep_tiles():
    """The tiles of the three buildings, in cells the colony leaves free."""
    return {
        "lava": Tile((8, 12, 1, 1), lights.solid(LAVA)),
        "molten": Tile((9, 12, 1, 1), lights.solid(MOLTEN)),
        "ember": Tile((10, 12, 1, 1), lights.solid(EMBER)),
        "blue": Tile((11, 12, 1, 1), lights.solid(BLUE)),
        "porthole_blue": Tile((12, 12, 2, 2), lights.porthole(BLUE)),
        "panes_blue": Tile((14, 12, 2, 2), lights.panes(BLUE, across=2, up=2)),
        "ribbon_blue": Tile((8, 13, 4, 1), lights.ribbon(BLUE)),
        "ribbon_lava": Tile((8, 14, 4, 1), lights.ribbon(LAVA)),
        "magma": Tile((8, 8, 4, 4), magma, seamless=True),
        "basalt": Tile((12, 8, 4, 4), basalt, seamless=True),
        "plates": Tile((0, 10, 4, 4), plates, seamless=True),
        "hatch": Tile((12, 14, 2, 2), hatch),
    }

