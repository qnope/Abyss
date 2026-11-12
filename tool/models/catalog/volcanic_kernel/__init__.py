"""The volcanic kernel: the base's own kernel of the volcano, the forge of the
Ancients that the player raises level by level, up to level 10 for the
victory, on the island's pad at the far corner (2 cells). A heart of fire that
grows with its level: red embers, then lava, then a blaze. (The map's volcano
and its Noyau are another model; this one is the building of the base.)

Three tiers that add up (the game shows Tier1 for levels 1-3, Tier1 + Tier2
for 4-7, all three from 8):
  Tier1  a mound of black basalt, a crater with a small molten core, lava
         running down its flanks, iron bands, three vents;
  Tier2  six pillars of basalt caging the crater, a column of lava to a second
         orb in an iron ring, pipes, reef;
  Tier3  its crown: six obsidian prongs arching to a flame (the node Flame),
         a ring of lava round the orb, broad lava falls, a moat of fire,
         floating shards.

Warm orange and red lights tell it from the others. Origin at the centre of
the pad's top, Blender Z up."""

from catalog import palette
from catalog.textures import colony
from catalog.textures.deep import deep_tiles
from catalog.volcanic_kernel import mound, tier2, tier3
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "volcanic_kernel"
SEED = 4411
MATERIALS = palette.BUILDING
ATLAS = colony.atlas(deep_tiles())
BUDGET = Budget(triangles=16_000, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.4, floor=0.4,
                      strength={"reef": 0.5, "algae": 0.45, "lamp": 0.0, "glass": 0.4})
FAMILY = "building"
PORTRAIT = True
TIERS = ("Tier1", "Tier2", "Tier3")
NODES = [*TIERS, "Tier3/Flame"]


def build(model):
    mound.tier1(model, "Tier1")
    tier2.tier2(model, "Tier2")
    tier3.tier3(model, "Tier3")
