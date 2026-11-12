"""The coral mine: a shaft sunk into the reef, on its pad of two cells (the
island's south-west, off the headquarters' spur). A collar of hazard stripes
round a pit that glows pink with the coral lode, a lattice headframe over it
with its sheave and cable, a winch house, and the rails of a coral cart
leading out toward the walkway. It grows with its level in 3 tiers that add
up: Tier1 the shaft, headframe, winch and cart; Tier2 the works (an ore bin,
a crusher, a belt carrying coral across the yard); Tier3 the crown: the
headframe's mast rising on, a crown wheel (the node CrownWheel) and a pink
beacon, and the lode breaking through in crystals. Pink is its colour.

Origin at the centre of the pad's top, Blender Z up. The headframe's sheave
is the node Wheel (Tier1), turned by the game as the cable runs."""

from catalog import palette
from catalog.coral_mine import crown, shaft, works, yard
from catalog.textures import production
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "coral_mine"
SEED = 4202
MATERIALS = palette.BUILDING
ATLAS = production.atlas()
BUDGET = Budget(triangles=9_000, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.4, floor=0.3,
                      strength={"reef": 0.6, "algae": 0.45, "lamp": 0.0, "glass": 0.45})
GROUP = "CoralMine"
TIERS = [f"{GROUP}/Tier1", f"{GROUP}/Tier2", f"{GROUP}/Tier3"]
FAMILY = "building"
PORTRAIT = True
NODES = [GROUP, *TIERS, f"{TIERS[0]}/Wheel", f"{TIERS[2]}/CrownWheel"]


def build(model):
    shaft.shaft(model, TIERS[0])
    yard.yard(model, TIERS[0])
    works.works(model, TIERS[1])
    crown.crown(model, TIERS[2])
