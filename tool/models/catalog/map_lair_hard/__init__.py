"""The hard lair: a huge cliff of dark crimson, a great mouth glowing red
between two curved tusks, three rows of fangs, a crown of six horns and a
field of bones: the tallest lair, the darkest, the most toothed (1.2 high,
1.1 wide).

Not tintable. Front (the mouth) toward -y."""

from catalog import mapkit
from catalog.mapkit import lairs
from catalog.textures import map as tiles
from workshop.colors import linear

NAME = "map_lair_hard"
SEED = 7303
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("red", "ember", "dark", "coral")
BUDGET = mapkit.budget(4_800)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY]
SPEC = lairs.Lair(radius=0.5, height=1.0, colour=linear("#82161c"), mouth=(0.27, 0.24), tilt=30,
                  upper=11, lower=8, fang=0.18, glow="red", horns=6, horn=0.32, tusks=True, bones=6)


def build(model):
    lairs.build(model, SPEC)
