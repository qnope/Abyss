"""La Cheminée: a hydrothermal chimney, a transition post toward the next
level. A cluster of three black smokers, tapering towers of mineral rock
banded with sulphur yellow, each ending in a flared mouth with an amber glow,
the tallest breathing a column of dark smoke that drifts off to one side,
white tube worms at its foot. The tallest thin silhouette of the map after
the volcano (1.6 high with its smoke); the ring of lights on the floor round
it and the banner on a mast, in the node Tint, wear the holder's colour.

Tintable: Tint = the ring and the banner (neutral white by default, the
guardians' grey in the game). Front toward -y."""

import math

from catalog import colors, mapkit
from catalog.mapkit import post
from catalog.parts import bank
from catalog.parts.deep import swell
from catalog.textures import map as tiles
from workshop import noise, shapes, sweep
from workshop.colors import linear, scale

NAME = "map_cheminee"
SEED = 7402
FAMILY = mapkit.FAMILY
MATERIALS = mapkit.MATERIALS
ATLAS = tiles.atlas("amber", "red", "white", "basalt")
BUDGET = mapkit.budget(3_000)
OCCLUSION = mapkit.OCCLUSION
NODES = [mapkit.BODY, mapkit.TINT]
SOOT = linear("#2e2a36")
CRUST = linear("#c9a62a")
SMOKE = linear("#4a4a56")
# (x, y, height, radius) of the three smokers.
TOWERS = ((0.04, 0.06, 1.0, 0.13), (-0.2, -0.06, 0.7, 0.1), (0.22, -0.12, 0.5, 0.09))
BASE = 0.07


def build(model):
    atlas, rng, into = model.atlas, model.rng, mapkit.body(model)
    bank.bank(into, atlas, 0.45, BASE, scale(SOOT, 1.4), tile="basalt", seed=6)
    for k, (x, y, height, radius) in enumerate(TOWERS):
        _tower(into, atlas, x, y, height, radius, k)
    for k in range(3):  # smoke, drifting toward +x
        puff = shapes.sphere(0.1 + 0.03 * k, subdivisions=2).transform(
            (TOWERS[0][0] + 0.06 + 0.1 * k, TOWERS[0][1] + 0.03 * k, BASE + 1.08 + 0.15 * k))
        puff.displace(lambda p: p.normalized() * 0.03 * noise.fbm(p * 5, 3))
        into.add(puff, "hull", scale(SMOKE, 1.0 + 0.2 * k), atlas.solid("plain")(puff))
    for k in range(9):  # tube worms
        a = 2 * math.pi * k / 9 + 0.2
        worm = sweep.tube([(0, 0, 0), (0.01, 0.01, 0.05), (0.03, 0.01, 0.1)], [0.016, 0.014, 0.012], sides=5)
        worm.transform((0.3 * math.cos(a), 0.3 * math.sin(a), BASE - 0.02), (0, 0, a))
        into.add(worm, "hull", colors.WHITE, atlas.solid("plain")(worm))
        tip = shapes.octahedron(0.014).transform((0.3 * math.cos(a) + 0.03 * math.cos(a), 0.3 * math.sin(a), BASE + 0.09))
        into.add(tip, "lamp", colors.LAMP, atlas.solid("red")(tip))
    post.marks(model, atlas, 0.47, (-0.42, -0.28), mast=0.6, sides=12)


def _tower(into, atlas, x, y, height, radius, k):
    """A tapering smoker with sulphur bands and a flared mouth that glows."""
    top = BASE - 0.02 + height
    profile = [(radius * 1.5, -0.02), (radius * 1.25, height * 0.15), (radius, height * 0.5),
               (radius * 0.78, height * 0.9), (radius * 1.1, height), (radius * 0.8, height * 1.0 - 0.02)]
    body = swell(sweep.lathe(profile, sides=9), 5 + k, 0.025, 0.1)
    body.transform((x, y, BASE - 0.02))
    into.add(body, "reef", lambda p, n: scale(SOOT, 0.8 + 0.5 * max(noise.fbm(p * 6, k), 0.0)), atlas.tiled("basalt", 0.5)(body))
    for h in (0.3, 0.62, 0.84):
        r = radius * (1.25 - 0.45 * h) * 1.04
        band = sweep.lathe([(r, 0.0), (r * 1.06, 0.03), (r, 0.06)], sides=9).transform((x, y, BASE - 0.02 + height * h))
        into.add(band, "reef", CRUST, atlas.solid("plain")(band))
    mouth = shapes.cylinder(radius * 0.8, 0.02, sides=9, smooth=False).transform((x, y, top - 0.005))
    into.add(mouth, "lamp", colors.LAMP, atlas.solid("amber")(mouth))
