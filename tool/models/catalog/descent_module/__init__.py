"""The descent module: the vehicle that carries the units down to the next
level, on the island's pad at the east (2 cells). A deck of grey-green steel
round a well of blue light, a gantry of four leaning legs under a winch
housing, and the descent pod, a capsule with blue ports, hanging over the well
on its cables, a hut beside it. Blue is its light.

Three tiers that add up (the game shows Tier1, Tier1 + Tier2, all three):
  Tier1  the deck, the well, the gantry, the winch, the pod, the hut;
  Tier2  cross-bracing, a railed catwalk and ladder, ballast tanks, counter-
         weights, drums, floodlights, the pod's clamps and fins, reef;
  Tier3  its crown: a halo of light round the well, a mast with the node
         Beacon, a dish, a jib with a crate, posts of light, the pod's
         armour and thrusters.

Origin at the centre of the pad's top, Blender Z up."""

from catalog import palette
from catalog.descent_module import tier1, tier2, tier3
from catalog.textures import colony
from catalog.textures.deep import deep_tiles
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "descent_module"
SEED = 4207
MATERIALS = palette.BUILDING
ATLAS = colony.atlas(deep_tiles())
BUDGET = Budget(triangles=14_000, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.4, floor=0.45,
                      strength={"reef": 0.6, "algae": 0.45, "lamp": 0.0, "glass": 0.4})
FAMILY = "building"
PORTRAIT = True
TIERS = ("Tier1", "Tier2", "Tier3")
NODES = [*TIERS, "Tier3/Beacon"]


def build(model):
    tier1.tier1(model, "Tier1")
    tier2.tier2(model, "Tier2")
    tier3.tier3(model, "Tier3")
