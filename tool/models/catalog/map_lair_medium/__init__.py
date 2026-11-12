"""The medium lair: a bigger mound of bright red rock, a wider mouth with two
rows of fangs over a glowing ember, four horns on its crown and a litter of
bones. Taller and redder than the easy one (0.85 high, 1.0 wide).

Not tintable. Front (the mouth) toward -y."""

from catalog import mapkit
from catalog.mapkit import lairs
from catalog.textures import map as tiles
from workshop.colors import linear

NAME = "map_lair_medium"
SEED = 7302
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("red", "ember", "dark", "coral")
BUDGET = mapkit.budget(3_200)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY]
SPEC = lairs.Lair(radius=0.45, height=0.75, colour=linear("#d03a36"), mouth=(0.19, 0.15), tilt=34,
                  upper=8, lower=5, fang=0.12, glow="ember", horns=4, horn=0.22, tusks=False, bones=4)


def build(model):
    lairs.build(model, SPEC)
