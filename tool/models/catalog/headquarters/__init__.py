"""The headquarters: the colony's command keep, on the island's round pad
(3 cells, at the heart of the four avenues). An octagonal pressure hull on a
heavy plinth, an airlock toward each avenue, a gallery around a bridge of
cyan windows under a ribbed glass cupola, and a mast with a beacon on top:
the tallest silhouette of the base, read from afar by its cyan crown and
the warm portholes of its quarters. Its tanks, generator and pipes stand
at the diagonals, and the reef has taken hold of its foot.

Origin at the centre of the pad's top, Blender Z up. The beacon and the dish
are nodes of their own, for the game to turn them."""

from catalog import palette
from catalog.headquarters import airlocks, annexes, bridge, deck, keep
from catalog.textures import colony
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "headquarters"
SEED = 3101
MATERIALS = palette.BUILDING
ATLAS = colony.atlas()
# 20k triangles: the base's centrepiece, the tallest, seen closest; one atlas of 1024 px
# shared by its five materials (five draw calls, and two for the nodes).
BUDGET = Budget(triangles=20_000, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.5, floor=0.3,
                      strength={"reef": 0.6, "algae": 0.45, "lamp": 0.0, "glass": 0.5})
GROUP = "Headquarters"
NODES = [GROUP, f"{GROUP}/Beacon", f"{GROUP}/Dish"]


def build(model):
    keep.keep(model, GROUP)
    airlocks.airlocks(model, GROUP)
    bridge.bridge(model, GROUP)
    deck.deck(model, GROUP)
    annexes.annexes(model, GROUP)
