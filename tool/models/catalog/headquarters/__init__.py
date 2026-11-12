"""The headquarters: the colony's command keep, on the island's round pad
(3 cells, at the heart of the four avenues). Three tiers that add up. Tier 1,
the command post: an octagonal pressure hull on a heavy plinth, an airlock
toward each avenue, a gallery around a drum of cyan bridge windows. Tier 2,
the headquarters: a ribbed glass cupola and a mast, the tanks, generator and
pipes at the diagonals, cargo on the gallery, more reef. Tier 3, the command
tower: a lattice of four legs closing in over the cupola to a beacon, a great
dish, sensor pods on the gallery and a glowing rail: by far the tallest
silhouette of the base, read from afar by its cyan crown and the warm
portholes of its quarters.

Origin at the centre of the pad's top, Blender Z up. The beacon and the dish
are nodes of their own, for the game to turn them. The hull of the keep and
those two nodes are the root's own, shown whatever the tier (the game finds them
there); the tiers add the rest."""

from catalog import palette
from catalog.headquarters import airlocks, annexes, bridge, deck, keep, tower
from catalog.textures import colony
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "headquarters"
SEED = 3101
MATERIALS = palette.BUILDING
ATLAS = colony.atlas()
# 20k triangles: the base's centrepiece, the tallest, seen closest; one atlas of 1024 px
# shared by its five materials (the tiers' nodes draw one mesh per material each).
BUDGET = Budget(triangles=20_000, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.5, floor=0.3,
                      strength={"reef": 0.6, "algae": 0.45, "lamp": 0.0, "glass": 0.5})
GROUP = "Headquarters"
FAMILY = "building"
PORTRAIT = True
NODES = [GROUP, f"{GROUP}/Headquarters_hull", *(f"{GROUP}/Tier{k}" for k in (1, 2, 3)),
         f"{GROUP}/Beacon", f"{GROUP}/Dish"]


def build(model):
    one, two, three = (f"{GROUP}/Tier{k}" for k in (1, 2, 3))
    keep.keep(model, GROUP)
    bridge.fixtures(model, GROUP)
    airlocks.airlocks(model, one)
    bridge.gallery(model, one)
    annexes.reefs(model, one, (0, 1))
    bridge.cupola(model, two)
    deck.deck(model, two)
    annexes.works(model, two)
    annexes.reefs(model, two, (2, 3, 4))
    tower.tower(model, three)
    annexes.reefs(model, three, (5, 6))
