"""The coral citadel: a fortress the colony grew rather than built, on its
pad at the base's front corner (2 cells), well inside the coral rampart that
rises around the base with it. Three tiers that add up. Tier 1, the keep: a
swelling polyp of grown stone bound by riveted bands, its calyx opening
around the pink Heart, a low curtain of living rock with its gatehouse. Tier
2, the stronghold: four round towers with living cups and thorns, merlons and
thorns along the curtain, anemones on the calyx. Tier 3, the crown of thorns:
a cage of tentacles closing over the Heart, spires and coral arches binding
the towers to the keep, a halo of pink lights. Its spiky silhouette and its
pink lights tell it apart.

Origin at the centre of the pad's top, Blender Z up. The heart is the node
Heart (the root's own, shown at every tier), for the game to make it pulse."""

from catalog import palette
from catalog.coral_citadel import crown, keep, towers, walls
from catalog.textures import colony
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "coral_citadel"
SEED = 1029
MATERIALS = palette.BUILDING
ATLAS = colony.atlas()
# 18k triangles for the three tiers: walls, towers and a keep of grown stone, cut
# fine so that their lumpy outline reads, thorns and tentacles; the colony's atlas
# (1024 px), four materials (no glass).
BUDGET = Budget(triangles=18_000, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.45, floor=0.3,
                      strength={"reef": 0.75, "algae": 0.45, "lamp": 0.0})
GROUP = "CoralCitadel"
FAMILY = "building"
PORTRAIT = True
NODES = [GROUP, *(f"{GROUP}/Tier{k}" for k in (1, 2, 3)), f"{GROUP}/Heart"]


def build(model):
    one, two, three = (f"{GROUP}/Tier{k}" for k in (1, 2, 3))
    keep.keep(model, one, GROUP)
    walls.curtain(model, one)
    towers.gatehouse(model, one)
    towers.clusters(model, one, (0, 1, 2))
    towers.towers(model, two)
    walls.battlements(model, two)
    keep.anemones(model, two)
    towers.clusters(model, two, (3, 4, 5))
    crown.crown(model, three)
    towers.clusters(model, three, (6, 7, 8))
