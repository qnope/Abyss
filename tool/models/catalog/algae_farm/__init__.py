"""The algae farm: the colony's kitchen garden, on its pad of two cells (the
east of the island, off the headquarters' spur). A glasshouse of lit green
panes on a steel deck, nutrient basins where kelp grows, and a squat tank
that feeds it all. It grows with its level in 3 tiers that add up: Tier1 the
glasshouse, a basin and the tank; Tier2 a ridge lantern on the glasshouse,
a second basin under a trellis of kelp on ropes and a harvest drone (the
node Drone, hovering); Tier3 the bioreactor, a tower of glowing broth
crowning the tank. Green light is its colour, the only large glow of the base
that is neither cyan nor pink.

Origin at the centre of the pad's top, Blender Z up. The glasshouse runs
along x, its door at the west end, toward the walkway."""

from catalog import palette
from catalog.algae_farm import basins, hall, reactor
from catalog.textures import production
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "algae_farm"
SEED = 4101
MATERIALS = palette.BUILDING
ATLAS = production.atlas()
BUDGET = Budget(triangles=8_000, materials=4, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.4, floor=0.3,
                      strength={"reef": 0.6, "algae": 0.45, "lamp": 0.0, "glass": 0.5})
GROUP = "AlgaeFarm"
TIERS = [f"{GROUP}/Tier1", f"{GROUP}/Tier2", f"{GROUP}/Tier3"]
FAMILY = "building"
PORTRAIT = True
NODES = [GROUP, *TIERS, f"{TIERS[1]}/Drone"]


def build(model):
    hall.hall(model, TIERS[0])
    basins.first(model, TIERS[0])
    reactor.tank(model, TIERS[0])
    hall.lantern(model, TIERS[1])
    basins.second(model, TIERS[1])
    reactor.column(model, TIERS[2])
