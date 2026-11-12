"""Level 2, the twilight mid-depths ("Depths"): cold blue-grey silt, little
light, specks of marine snow; the life that survives there stands out in
violet and ember (sea fans, tube sponges, a few worms) against slate rubble,
along the borders of each cell, the middle left bare."""

from catalog.seabed import life, props
from catalog.seabed.level import Level
from workshop.colors import linear

SILT = linear("#6b7c97")
PATCH = linear("#566d92")
SLATE = linear("#4f5f7d")
SLATE_PALE = linear("#6a7690")
VIOLET, VIOLET_TIP = linear("#c4a0f7"), linear("#f0e2ff")
MAGENTA = linear("#d46fb0")
EMBER, EMBER_TIP = linear("#d0653a"), linear("#ffc27a")


def fans(tile):
    """Two sea fans leaning together, a sponge cluster, small stones."""
    rng = tile.rng
    tile.mound(-0.28, 0.28, 0.2, 0.03)
    tile.stain(0.3, -0.3, 0.3, linear("#4a5f86"))
    tile.lay()
    tile.put(life.fan(rng, 0.34, VIOLET), -0.3, 0.3, 0.4)
    tile.put(life.fan(rng, 0.26, MAGENTA), -0.14, 0.38, 1.9)
    tile.put(life.sponge(rng, 0.3, EMBER), 0.32, -0.3)
    tile.put(props.pebbles(rng, 0.1, SLATE_PALE, 3), 0.34, 0.2)
    tile.put(props.rock(rng, 0.14, SLATE), -0.36, -0.28, 0.7)


def garden(tile):
    """A garden of tube sponges and worms, a slab between."""
    rng = tile.rng
    tile.mound(0.3, 0.3, 0.2, 0.03)
    tile.stain(-0.3, -0.3, 0.28, linear("#6a6f95"))
    tile.lay()
    tile.put(life.sponge(rng, 0.34, EMBER, 4), 0.3, 0.3)
    tile.put(life.sponge(rng, 0.26, linear("#d9a441"), 3), 0.14, 0.4, 1.0)
    tile.put(life.worms(rng, 0.28, linear("#e2ddf0"), MAGENTA, 5), -0.3, -0.3)
    tile.put(props.star(rng, 0.1, MAGENTA), -0.4, 0.2, 0.9)
    tile.put(props.rock(rng, 0.15, SLATE_PALE), -0.3, 0.36, 2.0)


def rubble(tile):
    """Slate rubble with a fan growing out of it."""
    rng = tile.rng
    tile.mound(0.0, 0.0, 0.5, 0.02)
    tile.mound(0.28, -0.3, 0.2, 0.04)
    tile.lay()
    tile.put(props.rock(rng, 0.28, SLATE), 0.3, -0.3)
    tile.put(props.rock(rng, 0.18, SLATE_PALE), 0.14, -0.4, 1.1)
    tile.put(props.rock(rng, 0.15, SLATE), 0.42, -0.14, 0.2)
    tile.put(life.fan(rng, 0.3, VIOLET), 0.3, -0.18, 0.2)
    tile.put(life.worms(rng, 0.2, linear("#e2ddf0"), EMBER_TIP, 3), -0.32, 0.3)
    tile.put(props.pebbles(rng, 0.1, SLATE_PALE, 3), -0.3, -0.3)


def hidden(tile):
    """A cell under the fog: the silt dimmed, a rock in its silhouette."""
    tile.mound(-0.25, 0.25, 0.3, 0.015)
    tile.lay()
    tile.put(props.rock(tile.rng, 0.12, linear("#1c2638")), 0.28, 0.28)


LEVEL = Level(2, 22, SILT, PATCH, linear("#2f3d52"), linear("#18243a"), linear("#121c30"),
              (2, 2, 0.01), {"seed": 22, "ripple": (2, 2), "ripple_depth": 0.06,
                             "detail": "flecks"}, (fans, garden, rubble), (hidden, hidden))
