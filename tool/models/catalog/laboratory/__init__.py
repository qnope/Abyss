"""The laboratory: where the colony studies the deep, on its pad at the base's
west (2 cells). Three tiers that add up: a field lab (a scrubbed ceramic hall
with its specimen tanks), the research wing (a control room under its dish
and a bioreactor sphere of glowing liquid piped into the hall), and the
institute (a slim tower behind it, crowned by an atom of glowing rings). Teal
is its light, the one clean white building among the colony's rust and coral.

Origin at the centre of the pad's top, Blender Z up, the front turned toward
the game's camera. The atom is the node Atom, for the game to turn it."""

from catalog import palette
from catalog.laboratory import hall, tower, wing
from catalog.parts import Into
from catalog.parts.command import FACING, Collector, lay
from catalog.textures import command
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "laboratory"
SEED = 4417
MATERIALS = palette.BUILDING
ATLAS = command.atlas()
# 13k triangles for the three tiers: a hall and its tanks, a wing with a
# sphere, a tower; the command atlas (1024 px), four materials (no glass).
BUDGET = Budget(triangles=13_000, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.45, floor=0.3,
                      strength={"reef": 0.6, "algae": 0.45, "lamp": 0.0, "glass": 0.5})
GROUP = "Laboratory"
FAMILY = "building"
PORTRAIT = True
TIERS = (hall.tier1, wing.tier2, tower.tier3)
NODES = [GROUP, *(f"{GROUP}/Tier{k}" for k in (1, 2, 3)), f"{GROUP}/Tier3/Atom"]


def build(model):
    for number, maker in enumerate(TIERS, 1):
        collector = Collector()
        maker(collector, model)
        lay(Into(model, f"{GROUP}/Tier{number}"), collector, FACING)
