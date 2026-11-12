"""The solar panel: it catches the pale light that still reaches the reef.
A housing of inverters and batteries on a steel deck, on its pad of two cells
(north of the headquarters), a turntable and a mast, and the array: wings of
photovoltaic modules on a truss, tilted toward the light. It grows with its
level in 3 tiers that add up: Tier1 the housing; Tier2 battery cabinets of
lit gold cells beside it; Tier3 the collector, a tower whose gold lens sits
in rings of light, and gold-lit pylons. The array is the same at every
tier. Gold is its light, and its tilted blue wings are its silhouette.

Origin at the centre of the pad's top, Blender Z up. The array is the node
Array, its origin on the turntable's centre: the game turns it about the
vertical, whatever tier is shown."""

from catalog import palette
from catalog.solar_panel import array, bank, housing
from catalog.textures import production
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "solar_panel"
SEED = 2207
MATERIALS = palette.BUILDING
ATLAS = production.atlas()
BUDGET = Budget(triangles=7_500, materials=5, texture_px=1024)
OCCLUSION = Occlusion(rays=20, distance=0.4, floor=0.3,
                      strength={"reef": 0.6, "algae": 0.45, "lamp": 0.0, "glass": 0.4})
GROUP = "SolarPanel"
FAMILY = "building"
PORTRAIT = True
ARRAY = f"{GROUP}/Array"
TIERS = [f"{GROUP}/Tier1", f"{GROUP}/Tier2", f"{GROUP}/Tier3"]
NODES = [GROUP, ARRAY, *TIERS]


def build(model):
    housing.housing(model, TIERS[0])
    array.turntable(model, TIERS[0])
    array.array(model, ARRAY)
    bank.batteries(model, TIERS[1])
    bank.collector(model, TIERS[2])
    bank.pylons(model, TIERS[2])
