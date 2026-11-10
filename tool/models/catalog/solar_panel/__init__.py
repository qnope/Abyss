"""The solar panel: it catches the pale light that still reaches the reef.
A squat housing of batteries and inverters on the pad (2 cells, north of
the headquarters), a turntable and a mast, and the array: two wings of
photovoltaic modules on a truss, tilted toward the light, a gold collector
glowing above them. Its gold lights (charge gauges, the turntable's ring,
the collector) tell it from afar; its broad tilted wings are its silhouette.

Origin at the centre of the pad's top, Blender Z up. The array is the node
Array, its origin on the mast's pivot, for the game to turn it toward the
light."""

from catalog import palette
from catalog.solar_panel import array, housing
from catalog.textures import colony
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "solar_panel"
SEED = 2207
MATERIALS = palette.BUILDING
ATLAS = colony.atlas()
# 12k triangles: a two-cell building with a large but simple array; the
# colony's atlas (1024 px), five materials, eight draw calls with the array.
BUDGET = Budget(triangles=12_000, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.4, floor=0.3,
                      strength={"reef": 0.6, "algae": 0.45, "lamp": 0.0, "glass": 0.4})
GROUP = "SolarPanel"
NODES = [GROUP, f"{GROUP}/Array"]


def build(model):
    housing.housing(model, GROUP)
    array.array(model, GROUP)
