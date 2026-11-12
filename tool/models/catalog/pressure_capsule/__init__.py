"""The pressure capsule: the high-pressure capsule that lets the army assault
the hydrothermal chimneys, on the island's pad at the south (2 cells). A
steel plinth, a sphere of pressure hull (white above, steel blue below,
bolted at the equator) cradled by four legs, one big cyan viewport looking
out toward the camera, yellow gas bottles piped to it. White and steel blue
with cyan lights tell it from the others.

Three tiers that add up (the game shows Tier1, Tier1 + Tier2, all three):
  Tier1  the plinth, the sphere and its viewport, hatch, legs and bottles;
  Tier2  armoured ribs and belly, portholes, more bottles, floodlights, the
         two black chimneys with glowing vents, reef;
  Tier3  its crown: two gimbal rings studded with cyan lights on pivot
         posts, seams of light at the equator, a mast with the node Beacon,
         a drill arm.

Origin at the centre of the pad's top, Blender Z up."""

from catalog import palette
from catalog.pressure_capsule import tier1, tier2, tier3
from catalog.textures import colony
from catalog.textures.deep import deep_tiles
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "pressure_capsule"
SEED = 4301
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
