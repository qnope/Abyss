"""The barracks: where the colony drills its troops, on its pad at the base's
south (2 cells) and at the back of the army's parade ground (a round plot
2.3 wide: the building stays within it). Three tiers that add up: a bunker
hall with its door, banner and harpoon rack; the garrison (a gate tower with
its searchlight, a bunk module on the roof); the fortress (a keep tower under
its great banner, harpoon launchers, a crenellated roof, a portal lit in red).
Crimson cloth and red lights tell it from the others.

Origin at the centre of the pad's top, Blender Z up, the front turned toward
the game's camera."""

from catalog import palette
from catalog.barracks import annex, fortress, hall
from catalog.parts import Into
from catalog.parts.command import FACING, Collector, lay
from catalog.textures import command
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "barracks"
SEED = 5233
MATERIALS = palette.BUILDING
ATLAS = command.atlas()
# 12k triangles for the three tiers: three armoured blocks, towers, banners and
# a little reef; the command atlas (1024 px), four materials (no glass).
BUDGET = Budget(triangles=12_000, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.45, floor=0.3,
                      strength={"reef": 0.6, "algae": 0.45, "lamp": 0.0, "glass": 0.5})
GROUP = "Barracks"
FAMILY = "building"
PORTRAIT = True
TIERS = (hall.tier1, annex.tier2, fortress.tier3)
NODES = [GROUP, *(f"{GROUP}/Tier{k}" for k in (1, 2, 3))]


def build(model):
    for number, maker in enumerate(TIERS, 1):
        collector = Collector()
        maker(collector, model)
        lay(Into(model, f"{GROUP}/Tier{number}"), collector, FACING)
