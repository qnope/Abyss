"""The hard things lying on the sea floor, a few dozen triangles each: rocks,
pebbles, shells, sea stars, basalt stubs and the specks of a glowing pit.
Each takes the tile's random generator, a [size] and a colour, and gives
its parts as (geometry, material, paint), its foot on z = 0 at the origin.
They stay low (under 0.18): what stands on the cell must read above them."""

import math

from mathutils import Vector

from catalog import colors, paints
from workshop import noise, shapes
from workshop.colors import scale


def rock(rng, size, colour):
    """A rounded rock, flat underneath, with a faceted skin."""
    seed = rng.randrange(900)
    stone = shapes.sphere(1.0, subdivisions=1)
    stone.sharp_angle = math.radians(60)
    squash = Vector((rng.uniform(1.0, 1.4), rng.uniform(0.8, 1.1), rng.uniform(0.45, 0.65)))
    stone.displace(lambda p: p.normalized() * 0.2 * noise.value(p * 1.4, seed))
    stone.verts = [Vector((v.x * squash.x, v.y * squash.y, max(v.z * squash.z, -0.1)))
                   for v in stone.verts]
    stone.transform((0, 0, 0.1 * size), (0, 0, rng.uniform(0, 6.28)), scale=size)
    return [(stone, "seabed", paints.worked(colour, seed, mottle=0.25, frequency=5.0))]


def pebbles(rng, size, colour, count=3):
    """A few small stones strewn over [size]."""
    parts = []
    for _ in range(count):
        a, r = rng.uniform(0, 6.28), rng.uniform(0.0, 1.0) * size
        stone = shapes.sphere(rng.uniform(0.35, 0.6) * size * 0.45, subdivisions=1)
        stone.sharp_angle = math.radians(60)
        stone.transform((math.cos(a) * r, math.sin(a) * r, 0.0), scale=(1, rng.uniform(0.7, 1), 0.5))
        parts.append((stone, "seabed", scale(colour, rng.uniform(0.85, 1.15))))
    return parts


def shell(rng, size, colour):
    """A small fan shell lying flat."""
    fan = shapes.cylinder(0.5, 0.35, sides=6, top_radius=0.3, smooth=False, bottom=False)
    fan.transform((0, 0, 0), (rng.uniform(-0.2, 0.2), 0, rng.uniform(0, 6.28)),
                  scale=(size, size * 0.85, size * 0.35))
    return [(fan, "seabed", paints.organic(scale(colour, 0.8), colour, rng.randrange(99),
                                           frequency=12, height=0.12))]


def star(rng, size, colour):
    """A five-armed sea star, flat."""
    outline = [(math.cos(math.pi * k / 5) * (1.0 if k % 2 == 0 else 0.42),
                math.sin(math.pi * k / 5) * (1.0 if k % 2 == 0 else 0.42)) for k in range(10)]
    body = shapes.prism(outline, 0.2, bevel=0.0, bottom=False)
    body.transform((0, 0, 0), (0, 0, rng.uniform(0, 6.28)), scale=(size, size, size * 0.2))
    return [(body, "seabed", paints.organic(scale(colour, 0.7), colour, 3, height=0.04))]


def column(rng, size, colour):
    """A stub of basalt column, a hexagon of a few heights."""
    height = rng.uniform(0.5, 1.0)
    stub = shapes.prism(shapes.polygon(6, 0.5, rng.uniform(0, 1.0)), height, bevel=0.0,
                        top=0.9, bottom=False)
    stub.transform((0, 0, 0), (rng.uniform(-0.12, 0.12), rng.uniform(-0.12, 0.12), 0),
                   scale=(size, size, size * 0.7))
    return [(stub, "seabed", paints.worked(colour, rng.randrange(99), mottle=0.2))]


def speck(rng, size):
    """A glowing speck, a lit dot lying in the silt."""
    return [(shapes.octahedron(size).transform((0, 0, size * 0.2), scale=(1, 1, 0.6)),
             "glow", colors.GLOW_CYAN)]
