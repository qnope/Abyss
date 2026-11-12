"""The tiles of the contents of the map, in a 512 px atlas cut in 8 x 8 cells
(64 px): the colony's lights and plates, the reef's pores, basalt and magma,
and the colours the map's contents glow with. Every content takes only the
tiles it maps (atlas(*names)), laid out by pack() in the cells it needs, so
that its PNG stays small: a content seen from far wants colour, not detail."""

import numpy

from catalog.textures import deep, lights, living, metal
from catalog.textures.lights import AMBER, CYAN, DARK, GOLD, PINK, WHITE
from workshop.atlas import Atlas, Tile
from workshop.colors import linear

GRID = 8
SIZE = 512
RED = numpy.array(linear("#ff3b2f")) * 0.85
GREEN = numpy.array(linear("#3cf08a")) * 0.5
VIOLET = numpy.array(linear("#7a50ff")) * 0.9
TEAL = numpy.array(linear("#22e0c8")) * 0.8
SULPHUR = numpy.array(linear("#e8d23a")) * 0.8
ORE = numpy.array(linear("#3a8dff")) * 0.85
BULLION = numpy.array(linear("#e8900c")) * 0.62

SOLID = {"plain": (1.0, 1.0, 1.0), "dark": DARK, "white": WHITE, "amber": AMBER, "cyan": CYAN,
         "pink": PINK, "gold": GOLD, "red": RED, "green": GREEN, "violet": VIOLET, "teal": TEAL,
         "sulphur": SULPHUR, "ore": ORE, "blue": deep.BLUE, "bullion": BULLION, "lava": deep.LAVA, "molten": deep.MOLTEN,
         "ember": deep.EMBER}
# name: (columns, rows, painter, seamless)
DETAIL = {
    "plate": (2, 2, metal.plate, False),
    "plate_wide": (4, 2, lambda c: metal.plate(c, across=2), False),
    "plate_tall": (2, 4, lambda c: metal.plate(c, up=2), False),
    "strap": (4, 1, metal.strap, False),
    "tread": (2, 2, metal.tread, False),
    "bolt": (1, 1, metal.bolt, False),
    "hazard": (2, 1, metal.hazard, False),
    "hatch": (2, 2, deep.hatch, False),
    "glass": (2, 2, lights.glass, False),
    "panes_cyan": (2, 2, lights.panes(CYAN, across=3, up=2), False),
    "porthole_cyan": (2, 2, lights.porthole(CYAN), False),
    "ribbon_cyan": (4, 1, lights.ribbon(CYAN), False),
    "weathered": (3, 3, metal.weathered, True),
    "plates": (3, 3, deep.plates, True),
    "coral": (3, 3, living.coral, True),
    "stone": (3, 3, living.reef_stone, True),
    "basalt": (3, 3, deep.basalt, True),
    "magma": (3, 3, deep.magma, True),
}


def pack(sizes):
    """Where each tile of [sizes] ({name: (columns, rows)}) goes in the grid:
    the biggest first, each in the first free spot reading rows from the top."""
    taken, cells = set(), {}
    for name in sorted(sizes, key=lambda n: (-sizes[n][0] * sizes[n][1], n)):
        width, height = sizes[name]
        spots = ((c, r) for r in range(GRID - height + 1) for c in range(GRID - width + 1))
        for column, row in spots:
            spot = {(column + i, row + j) for i in range(width) for j in range(height)}
            if not spot & taken:
                taken |= spot
                cells[name] = (column, row, width, height)
                break
        else:
            raise ValueError(f"no room for the tile {name} in the {GRID} x {GRID} grid")
    return cells


def atlas(*names):
    """The atlas holding the tiles [names] and the white one."""
    wanted = dict.fromkeys(("plain", *names))
    unknown = [n for n in wanted if n not in SOLID and n not in DETAIL]
    if unknown:
        raise KeyError(f"no tile {', '.join(unknown)}")
    cells = pack({n: (1, 1) if n in SOLID else DETAIL[n][:2] for n in wanted})
    tiles = {}
    for name, place in cells.items():
        if name in SOLID:
            tiles[name] = Tile(place, lights.solid(numpy.asarray(SOLID[name])))
        else:
            tiles[name] = Tile(place, DETAIL[name][2], DETAIL[name][3])
    return Atlas(SIZE, GRID, tiles)
