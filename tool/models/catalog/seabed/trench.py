"""Level 3, the abyssal trench ("Core"): black ash and basalt, cracked and
barely lit; the only colour is the cold glow of the vents' specks, pale
tube worms and the basalt's own blue. Basalt stubs and rock along the
borders of each cell, the middle left bare."""

from catalog.seabed import life, props
from catalog.seabed.level import Level
from workshop.colors import linear

ASH = linear("#434c62")
PATCH = linear("#2f384d")
BASALT = linear("#566580")
BASALT_DARK = linear("#3b4560")
WORM, WORM_TIP = linear("#e4e8f2"), linear("#e0486a")


def specks(tile, places, size=0.026):
    """A glowing speck at each of [places]."""
    for x, y in places:
        tile.put(props.speck(tile.rng, size), x, y, sink=-0.012)


def vent(tile):
    """A cluster of basalt stubs round a vent, glowing specks in its ash."""
    rng = tile.rng
    tile.mound(-0.3, 0.3, 0.22, 0.04)
    tile.stain(-0.3, 0.3, 0.24, linear("#2a3144"))
    tile.lay()
    for x, y, size in ((-0.3, 0.3, 0.2), (-0.17, 0.4, 0.13), (-0.42, 0.18, 0.12), (-0.38, 0.4, 0.1)):
        tile.put(props.column(rng, size, BASALT), x, y, rng.uniform(0, 1))
    tile.put(life.worms(rng, 0.24, WORM, WORM_TIP, 4), 0.32, -0.3)
    specks(tile, ((-0.1, 0.3), (-0.34, 0.1), (0.36, 0.18), (0.2, -0.4), (-0.4, -0.3)))


def ash(tile):
    """Dark rocks half sunk in an ash dune, pits glowing."""
    rng = tile.rng
    tile.mound(0.0, 0.0, 0.5, 0.025)
    tile.mound(0.3, -0.3, 0.16, -0.025)
    tile.lay()
    tile.put(props.rock(rng, 0.26, BASALT_DARK), 0.3, 0.3)
    tile.put(props.rock(rng, 0.17, BASALT), 0.14, 0.4, 1.3)
    tile.put(props.rock(rng, 0.14, BASALT_DARK), 0.42, 0.14, 2.2)
    tile.put(props.pebbles(rng, 0.1, BASALT, 3), -0.3, 0.3)
    specks(tile, ((0.3, -0.3), (0.38, -0.34), (0.26, -0.38), (-0.32, -0.28)), 0.03)


def worms(tile):
    """A colony of tube worms among basalt stubs."""
    rng = tile.rng
    tile.mound(-0.3, -0.3, 0.2, 0.03)
    tile.lay()
    tile.put(life.worms(rng, 0.3, WORM, WORM_TIP, 6), -0.3, -0.3)
    tile.put(life.worms(rng, 0.22, WORM, WORM_TIP, 4), -0.16, -0.4, 1.0)
    tile.put(props.column(rng, 0.14, BASALT), 0.32, 0.3)
    tile.put(props.column(rng, 0.1, BASALT_DARK), 0.4, 0.16, 1.0)
    tile.put(props.rock(rng, 0.15, BASALT_DARK), -0.3, 0.32, 0.4)
    specks(tile, ((0.1, 0.38), (0.36, -0.2), (-0.4, 0.1)))


def hidden(tile):
    """A cell under the fog: black ash, a stub in its silhouette."""
    tile.mound(0.25, -0.25, 0.3, 0.015)
    tile.lay()
    tile.put(props.column(tile.rng, 0.1, linear("#1a2030")), -0.28, 0.28)


LEVEL = Level(3, 33, ASH, PATCH, linear("#1c2232"), linear("#0f1422"), linear("#0a0e1a"),
              (1, 2, 0.008), {"seed": 33, "ripple": (1, 2), "ripple_depth": 0.05,
                              "detail": "ash"}, (vent, ash, worms), (hidden, hidden))
