"""The citadel's third tier, the crown of thorns: long tentacles rising out of
the calyx and closing in a cage around the Heart, a spire of living coral
over each tower, arches of coral binding the towers to the keep, and a halo
of pink lights around the calyx."""

import math

from mathutils import Vector

from catalog import colors
from catalog.coral_citadel.stone import living
from catalog.coral_citadel.towers import CORNERS
from catalog.coral_citadel.walls import HALF
from catalog.parts import Into, light, place, reef
from workshop import shapes, sweep
from workshop.builder import painted

CAGE = 12  # tentacles round the Heart
APEX = 2.2  # where the cage closes


def crown(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    for k in range(CAGE):
        a = 2 * math.pi * k / CAGE + rng.uniform(-0.1, 0.1)
        lean = rng.uniform(0.9, 1.0)
        path = [Vector((r * math.cos(a), r * math.sin(a), z)) for r, z in
                ((0.5, 1.52), (0.63 * lean, 1.7), (0.55 * lean, 1.92), (0.3, 2.1), (0.12, APEX - 0.02))]
        tentacle = sweep.tube(path, [0.034, 0.03, 0.024, 0.016, 0.008], sides=5)
        into.add(tentacle, "reef", painted(tentacle, living(rng.randrange(99), 1.3, APEX)),
                 atlas.tiled("coral", 0.4)(tentacle))
        if k % 3 == 0:
            place(into, [(shapes.octahedron(0.03), *light(atlas, "pink"))],
                  (0.12 * math.cos(a), 0.12 * math.sin(a), APEX + 0.02))
    for sx, sy in CORNERS:
        out = Vector((sx * 0.3, sy * 0.3, 1.0))
        place(into, reef.thorn(atlas, rng, 0.62, 0.05, out, colors.CORAL_DEEP, colors.CORAL_PINK),
              (sx * HALF, sy * HALF, 0.92))
        tip = Vector((sx * HALF, sy * HALF, 0.92)) + out.normalized() * 0.56
        place(into, [(shapes.octahedron(0.035), *light(atlas, "pink"))], tuple(tip))
        _arch(into, atlas, rng, math.atan2(sy, sx))
    for k in range(12):
        a = 2 * math.pi * (k + 0.5) / 12
        place(into, [(shapes.octahedron(0.026), *light(atlas, "pink"))],
              (0.67 * math.cos(a), 0.67 * math.sin(a), 1.6))


def _arch(into, atlas, rng, angle):
    """A bow of coral from a tower's cup to the keep's calyx."""
    c, s = math.cos(angle), math.sin(angle)
    path = [Vector((r * c, r * s, z)) for r, z in ((0.93, 0.95), (0.86, 1.25), (0.72, 1.43), (0.58, 1.5))]
    arch = sweep.tube(path, [0.05, 0.045, 0.04, 0.035], sides=6, cap=False)
    into.add(arch, "reef", painted(arch, living(rng.randrange(99), 0.9, 1.6)),
             atlas.tiled("coral", 0.4)(arch))
