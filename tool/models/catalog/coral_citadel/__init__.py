"""The coral citadel: a fortress the colony grew rather than built, on its
pad at the base's front corner (2 cells). A curtain of living coral stone
between four round towers, a gatehouse toward the headquarters' spur, and
at its heart a keep that swells, narrows and flares like a polyp, bound by
riveted bands, crowned by a gallery, a brain-coral dome and a ring of
thorns around the pink heart that feeds the rampart. Coral thorns bristle
from every wall: its spiky silhouette and its pink lights tell it apart.

Origin at the centre of the pad's top, Blender Z up. The heart is the node
Heart, for the game to make it pulse."""

from catalog import palette
from catalog.coral_citadel import keep, walls
from catalog.textures import colony
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "coral_citadel"
SEED = 1029
MATERIALS = palette.BUILDING
ATLAS = colony.atlas()
# 18k triangles: walls, towers and a keep of grown stone, cut fine so that
# their lumpy outline reads, and many thorns; the colony's atlas (1024 px),
# four materials (no glass): six draw calls with the heart.
BUDGET = Budget(triangles=18_000, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.45, floor=0.3,
                      strength={"reef": 0.75, "algae": 0.45, "lamp": 0.0})
GROUP = "CoralCitadel"
NODES = [GROUP, f"{GROUP}/Heart"]


def build(model):
    walls.walls(model, GROUP)
    keep.keep(model, GROUP)
