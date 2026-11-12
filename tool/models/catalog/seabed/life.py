"""The living things on the sea floor, low and cheap: blades of sea grass,
brain coral, branching coral, sea fans, tube sponges and tube worms. Same
contract as props.py: (geometry, material, paint) parts, foot on z = 0."""

import math

from mathutils import Vector

from catalog import paints
from workshop import shapes, sweep
from workshop.colors import mix, scale
from workshop.geometry import Geometry


def blades(rng, size, colour, tip, count=5):
    """A tuft of [count] blades leaning out, each a three-sided spike."""
    parts = []
    for k in range(count):
        a = 2 * math.pi * k / count + rng.uniform(-0.4, 0.4)
        lean = Vector((math.cos(a), math.sin(a), 0)) * rng.uniform(0.15, 0.45) * size
        height = size * rng.uniform(0.7, 1.0)
        path = [lean * t * t + Vector((0, 0, height * t)) + Vector((0.02 * math.cos(a), 0.02 * math.sin(a), 0))
                for t in (0.0, 0.5, 1.0)]
        blade = sweep.tube(path, [size * 0.07, size * 0.05, size * 0.01], sides=3, cap=False)
        parts.append((blade, "seabed", paints.organic(scale(colour, 0.6), mix(colour, tip, 0.6),
                                                      k, height=height)))
    return parts


def brain(rng, size, colour):
    """A dome of brain coral, grooved by its paint."""
    dome = sweep.lathe([(1.0, 0.0), (0.95, 0.35), (0.7, 0.7), (0.35, 0.92), (0.0, 1.0)], sides=8)
    dome.transform((0, 0, 0), (0, 0, rng.uniform(0, 6.28)), scale=(size, size, size * 0.5))
    return [(dome, "seabed", paints.organic(scale(colour, 0.7), colour, rng.randrange(99),
                                            frequency=14, variation=0.3, height=size * 0.5))]


def branch(rng, size, colour, tip):
    """A branching coral: a stem forking in three, tips paler."""
    parts = []
    stem = [Vector((0, 0, 0)), Vector((0, 0, size * 0.4))]
    parts.append((sweep.tube(stem, [size * 0.1, size * 0.08], sides=4, cap=False),
                  "seabed", paints.organic(scale(colour, 0.6), colour, 1, height=size)))
    for k in range(3):
        a = 2 * math.pi * k / 3 + rng.uniform(-0.5, 0.5)
        out = Vector((math.cos(a), math.sin(a), 0)) * size * 0.35
        path = [stem[1], stem[1] + out * 0.5 + Vector((0, 0, size * 0.25)),
                stem[1] + out + Vector((0, 0, size * 0.55))]
        parts.append((sweep.tube(path, [size * 0.07, size * 0.055, size * 0.03], sides=4),
                      "seabed", paints.organic(colour, tip, k, height=size)))
    return parts


def fan(rng, size, colour):
    """A sea fan: a thin upright plate with a scalloped crest."""
    outline = [(-0.5, 0.0), (0.5, 0.0), (0.7, 0.6), (0.4, 0.95), (0.15, 0.75), (0.0, 1.0),
               (-0.15, 0.75), (-0.4, 0.95), (-0.7, 0.6)]
    plate = Geometry([(x, -0.07, y) for x, y in outline] + [(x, 0.07, y) for x, y in outline],
                     [tuple(range(9)), tuple(reversed(range(9, 18)))]
                     + [(k, (k + 1) % 9, 9 + (k + 1) % 9, 9 + k) for k in range(9)])
    plate.transform((0, 0, 0), (0, 0, rng.uniform(0, 6.28)), scale=size)
    return [(plate, "seabed", paints.organic(scale(colour, 0.7), colour, 2, height=size))]


def sponge(rng, size, colour, count=3):
    """A cluster of tube sponges, open at the top."""
    parts = []
    for k in range(count):
        a = 2 * math.pi * k / count + rng.uniform(-0.3, 0.3)
        r = size * 0.28 * (k > 0)
        tube = shapes.cylinder(size * 0.17, size * rng.uniform(0.5, 1.0), sides=6,
                               top_radius=size * 0.13, bottom=False)
        tube.transform((math.cos(a) * r, math.sin(a) * r, 0))
        parts.append((tube, "seabed", paints.organic(scale(colour, 0.65), colour, 5 + k,
                                                     height=size)))
    return parts


def worms(rng, size, colour, tip, count=4):
    """Tube worms: pale thin tubes with a coloured plume."""
    parts = []
    for k in range(count):
        a = rng.uniform(0, 6.28)
        r = rng.uniform(0, 0.4) * size
        height = size * rng.uniform(0.6, 1.0)
        tube = shapes.cylinder(size * 0.05, height, sides=4, bottom=False)
        tube.transform((math.cos(a) * r, math.sin(a) * r, 0), (rng.uniform(-0.15, 0.15), 0, 0))
        parts.append((tube, "seabed", paints.organic(colour, tip, k, height=height, variation=0.1)))
    return parts
