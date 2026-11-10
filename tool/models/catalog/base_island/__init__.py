"""The base's island: the plateau the 11 buildings stand on, perched above the
abyss. Its deck is 12 x 12 cells, its top at z = 0, its origin at the deck's
centre; each building slot is an empty pad, a node of its own under Pads."""

from catalog import palette
from catalog.base_island import layout
from catalog.base_island.biolum import biolum
from catalog.base_island.body import body, columns, grout
from catalog.base_island.beds import beds
from catalog.base_island.deck import deck
from catalog.base_island.decor import decor
from catalog.base_island.pads import pads
from catalog.base_island.walkways import walkways
from catalog.base_island.hanging import hanging
from catalog.base_island.spire import rings, spire, stalactite
from catalog.base_island.strata import rock_paint
from catalog import colors
from mathutils import Vector
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "base_island"
SEED = 1207
MATERIALS = [palette.ROCK, palette.STONE, palette.METAL, palette.CORAL, palette.ALGAE,
             palette.GLOW, palette.GLOW_PINK]
BUDGET = Budget(triangles=80_000, materials=10)
OCCLUSION = Occlusion(rays=20, distance=1.0, floor=0.3,
                      strength={"coral": 0.55, "algae": 0.45, "glow": 0.0, "glow_pink": 0.0})
NODES = ["Island", "Pads"] + [f"Pads/{slot.node}" for slot in layout.SLOTS]

GROUP = "Island"
# Rock spikes under the plateau, around the spire: (top, length, radius, seed).
STALACTITES = ((Vector((-3.4, 2.6, -3.3)), 3.4, 1.0, 1), (Vector((3.2, -3.6, -3.2)), 2.6, 0.8, 2),
               (Vector((4.2, 3.0, -3.0)), 1.8, 0.6, 3), (Vector((-4.6, -2.4, -2.9)), 1.4, 0.55, 4),
               (Vector((0.6, 4.6, -3.1)), 2.1, 0.7, 5), (Vector((-1.5, -4.8, -3.0)), 1.6, 0.6, 6))


def build(model):
    sides, spire_rings = columns(), rings()
    model.add(GROUP, body(sides), "rock", rock_paint(3))
    model.add(GROUP, grout(), "rock", colors.GROOVE)
    model.add(GROUP, spire(spire_rings), "rock", rock_paint(5, depth_fade=0.045))
    for top, length, radius, seed in STALACTITES:
        model.add(GROUP, stalactite(top, length, radius, seed), "rock", rock_paint(7, 0.045))
    deck(model)
    walkways(model)
    decor(model)
    beds(model)
    hanging(model, sides)
    biolum(model, sides, spire_rings)
    pads(model)
