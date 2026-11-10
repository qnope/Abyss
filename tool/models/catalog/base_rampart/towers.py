"""The rampart's towers, which rise with it: a round bastion at each corner
and a post at each side of every gate. Each tier adds a drum of coral
stone on the last; the third crowns the bastions with merlons and coral and
the gate posts with a capital holding a lantern."""

import math

from mathutils import Vector

from catalog import colors
from catalog.base_rampart import crest, masonry, ring
from workshop import noise, shapes, sweep
from workshop.geometry import Geometry

# Per tier: (radius, bottom, height) of the drum, for bastions and posts.
BASTION = ((0.54, -0.1, 0.46), (0.47, 0.32, 0.42), None)
POST = ((0.29, -0.1, 0.5), (0.26, 0.36, 0.5), None)
LANTERN = 1.16


def towers(model, group, tier, rng):
    for x, y in ring.CORNERS:
        if BASTION[tier]:
            _drum(model, group, (x, y), *BASTION[tier], sides=14, rng=rng)
        else:
            _crown(model, group, (x, y), rng)
    for (x, y), _ in ring.gate_ends():
        if POST[tier]:
            _drum(model, group, (x, y), *POST[tier], sides=10, rng=rng)
        if tier == 1:
            band = shapes.cylinder(0.272, 0.04, sides=10, bottom=False, smooth=False)
            model.add(group, band.transform((x, y, 0.64)), "glow", colors.GLOW_CYAN)
        if tier == 2:
            _capital(model, group, (x, y), rng)


def _drum(model, group, at, radius, bottom, height, sides, rng):
    seed = rng.randrange(1000)
    drum = shapes.cylinder(radius, height, sides=sides, top_radius=radius * 0.92,
                           bevel=0.04, bottom=False)
    drum.sharp_angle = math.radians(50)
    drum.displace(lambda p: noise.vector(p * 3.0, seed) * Vector((0.03, 0.03, 0.012)))
    model.add(group, drum.transform((at[0], at[1], bottom)), "coral",
              masonry.coral_stone(rng, seed))


def _crown(model, group, at, rng):
    """Merlons around the bastion's top and a coral tuft in their ring."""
    radius, bottom, height = BASTION[1]
    top = bottom + height - 0.01
    for k in range(6):
        a = 2 * math.pi * (k + 0.5) / 6
        block = masonry.stone((0.24, 0.16, 0.19), rng.randrange(1000), batter=0.15, rough=0.02)
        place = (at[0] + math.cos(a) * radius * 0.78, at[1] + math.sin(a) * radius * 0.78, top)
        model.add(group, block.transform(place, (0, 0, a + math.pi / 2)), "coral",
                  masonry.coral_stone(rng, rng.randrange(1000)))
    for geometry, material, paint in crest.sprig(rng, 0.42):
        geometry.transform((at[0], at[1], top))
        model.add(group, geometry, material, paint)


def _capital(model, group, at, rng):
    """A flared capital, horns of coral curling up to a glowing lantern."""
    radius, bottom, height = POST[1]
    top = bottom + height
    profile = [(radius * 0.92, top - 0.02), (radius * 1.1, top + 0.06), (radius * 1.38, top + 0.12),
               (radius * 1.4, top + 0.17), (radius * 1.1, top + 0.19), (0.0, top + 0.2)]
    capital = sweep.lathe(profile, sides=10)
    seed = rng.randrange(1000)
    model.add(group, capital.transform((at[0], at[1], 0)), "coral", masonry.coral_stone(rng, seed))
    horns = Geometry()
    for k in range(3):
        a = 2 * math.pi * k / 3 + 0.5
        rim = Vector((math.cos(a), math.sin(a), 0))
        points = [rim * 0.27 + Vector((0, 0, top + 0.15)), rim * 0.24 + Vector((0, 0, top + 0.32)),
                  rim * 0.09 + Vector((0, 0, LANTERN + 0.02))]
        horns.extend(sweep.tube(points, [0.06, 0.045, 0.025], sides=5))
    model.add(group, horns.transform((at[0], at[1], 0)), "coral",
              masonry.coral_stone(rng, seed + 1))
    lantern = shapes.sphere(0.11, subdivisions=1).transform((at[0], at[1], LANTERN))
    model.add(group, lantern, "glow", colors.GLOW_CYAN)
