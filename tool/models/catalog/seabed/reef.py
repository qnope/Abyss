"""Level 1, the sunlit reef shallows ("Surface"): pale warm sand rippled by the
swell, caustics of sunlight, and a reef's small life along the borders of each
cell (sea grass, brain and branching coral, sea stars, shells, rocks), the
middle left bare for what stands on the cell."""

from catalog import colors
from catalog.seabed import life, props
from catalog.seabed.level import Level
from workshop.colors import linear

SAND = linear("#b4c0a8")
PATCH = linear("#78a8a2")
ROCK = linear("#7b8088")
GRASS, GRASS_TIP = colors.KELP, linear("#9fd46a")
STAR = linear("#e8884c")


def meadow(tile):
    """Sea grass in two corners, shells and a few pebbles."""
    rng = tile.rng
    tile.mound(0.28, -0.3, 0.2, 0.025)
    tile.stain(-0.3, 0.3, 0.3, linear("#6f9d79"))
    tile.lay()
    tile.put(life.blades(rng, 0.25, GRASS, GRASS_TIP, 6), -0.33, 0.31)
    tile.put(life.blades(rng, 0.2, GRASS, GRASS_TIP, 5), -0.2, 0.37, 1.0)
    tile.put(life.blades(rng, 0.22, GRASS, GRASS_TIP, 5), 0.34, -0.33, 2.0)
    tile.put(props.shell(rng, 0.1, colors.SHELL), 0.3, 0.3, 0.5)
    tile.put(props.shell(rng, 0.08, colors.SHELL), -0.36, -0.28, 2.1)
    tile.put(props.pebbles(rng, 0.09, ROCK), 0.33, 0.04)


def corals(tile):
    """Brain coral and a branching head with a sea star at their feet."""
    rng = tile.rng
    tile.mound(-0.3, -0.3, 0.2, 0.03)
    tile.stain(0.3, -0.3, 0.28, linear("#d9b690"))
    tile.lay()
    tile.put(life.brain(rng, 0.28, colors.BRAIN_TAN), -0.31, -0.3)
    tile.put(life.brain(rng, 0.18, colors.BRAIN_ROSE), -0.17, -0.38, 1.0)
    tile.put(life.branch(rng, 0.3, colors.CORAL_PINK, linear("#ffd1dc")), 0.32, 0.3)
    tile.put(life.branch(rng, 0.22, colors.CORAL_ORANGE, linear("#ffe1b8")), 0.4, 0.14, 2.0)
    tile.put(props.star(rng, 0.11, STAR), 0.3, -0.31, 0.8)
    tile.put(props.pebbles(rng, 0.08, ROCK, 2), -0.36, 0.2)


def rocks(tile):
    """A few boulders in a corner, algae on them, a wide shallow dune."""
    rng = tile.rng
    tile.mound(0.0, 0.0, 0.5, 0.025)
    tile.mound(-0.3, 0.3, 0.18, 0.035)
    tile.lay()
    tile.put(props.rock(rng, 0.26, ROCK), -0.3, 0.3)
    tile.put(props.rock(rng, 0.17, linear("#8a8d93")), -0.14, 0.38, 1.4)
    tile.put(props.rock(rng, 0.14, ROCK), -0.4, 0.15, 0.6)
    tile.put(life.blades(rng, 0.22, GRASS, GRASS_TIP, 5), -0.2, 0.26, 0.4)
    tile.put(life.brain(rng, 0.17, colors.BRAIN_OLIVE), 0.32, -0.3)
    tile.put(props.star(rng, 0.09, STAR), 0.38, 0.0, 2.2)


def hidden(tile):
    """A cell under the fog: the sand dimmed, a rock or two in its silhouette."""
    tile.mound(0.25, 0.25, 0.3, 0.015)
    tile.lay()
    tile.put(props.rock(tile.rng, 0.12, linear("#2c3b46")), -0.28, -0.28)


LEVEL = Level(1, 11, SAND, PATCH, linear("#4b5a66"), linear("#243a45"), linear("#1c2f3a"),
              (3, 1, 0.012), {"seed": 11, "ripple": (3, 1), "ripple_depth": 0.07,
                              "detail": "caustics"}, (meadow, corals, rocks), (hidden, hidden))
