"""The ore extractor: a deep-bore rig sunk into the bedrock, on its pad of two
cells (the island's east edge, beside the avenue). A drill collar ringed with
blue light under a tripod rig on hydraulic jacks, its drill string (the node
Drill) turning, an engine block and a pressure tank beside it, bedrock
outcrops veined with glowing blue ore and crystals of it breaking out. It
grows with its level in 3 tiers that add up: Tier1 the rig, engine and tank;
Tier2 a belt carrying the ore up to a hopper, a control cab and a second
tank; Tier3 a tall silo fed by a second belt, a beacon on the rig and the
lode in bigger crystals. Blue is its colour; its diagonal belts and stocky
silo tell it from the mine's lattice tower.

Origin at the centre of the pad's top, Blender Z up."""

from catalog import palette
from catalog.ore_extractor import crown, line, plant, rig
from catalog.textures import production
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "ore_extractor"
SEED = 4303
MATERIALS = palette.BUILDING
ATLAS = production.atlas()
BUDGET = Budget(triangles=9_500, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.4, floor=0.3,
                      strength={"reef": 0.6, "algae": 0.45, "lamp": 0.0, "glass": 0.45})
GROUP = "OreExtractor"
TIERS = [f"{GROUP}/Tier1", f"{GROUP}/Tier2", f"{GROUP}/Tier3"]
FAMILY = "building"
PORTRAIT = True
NODES = [GROUP, *TIERS, f"{TIERS[0]}/Drill"]


def build(model):
    rig.rig(model, TIERS[0])
    plant.plant(model, TIERS[0])
    line.line(model, TIERS[1])
    crown.crown(model, TIERS[2])
