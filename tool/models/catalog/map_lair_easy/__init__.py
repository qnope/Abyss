"""The easy lair: a small den of salmon coral, a dark mouth on its front slope
with a few fangs and a pair of red eyes, two short horns and bones before it.
The smallest and palest of the three lairs (0.55 high, 0.85 wide).

Not tintable. Front (the mouth) toward -y."""

from catalog import mapkit
from catalog.mapkit import lairs
from catalog.textures import map as tiles
from workshop.colors import linear

NAME = "map_lair_easy"
SEED = 7301
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("red", "ember", "dark", "coral")
BUDGET = mapkit.budget(2_000)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY]
SPEC = lairs.Lair(radius=0.4, height=0.5, colour=linear("#e0736a"), mouth=(0.13, 0.1), tilt=38,
                  upper=5, lower=3, fang=0.08, glow=None, horns=2, horn=0.12, tusks=False, bones=2)


def build(model):
    lairs.build(model, SPEC)
