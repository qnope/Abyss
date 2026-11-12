"""Profiles drawn in a side view and pulled along x: vaults, arches, hulls,
ribs. The outline is in (y, z), counter-clockwise seen from +x."""

import math

from mathutils import Matrix

from workshop import shapes, sweep

# (x, y, z) -> (z, x, y): a prism's outline (a, b) lands on (y, z), its height on x.
_TO_X = Matrix(((0, 0, 1, 0), (1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 0, 1)))


def along_x(outline, length, bevel=0.0, top=1.0, smooth=False, bottom=True):
    """The (y, z) [outline] pulled [length] along x, centred on x = 0."""
    prism = shapes.prism(outline, length, bevel=bevel, top=top, smooth=smooth, bottom=bottom)
    return prism.apply(_TO_X).transform((-length / 2, 0, 0))


def arc(radius_y, radius_z, steps=8, start=0.0, end=math.pi, centre=(0.0, 0.0)):
    """Points along an ellipse of the (y, z) plane, from [start] to [end]."""
    cy, cz = centre
    return [(cy + radius_y * math.cos(start + (end - start) * k / steps),
             cz + radius_z * math.sin(start + (end - start) * k / steps)) for k in range(steps + 1)]


def vault(depth, rise, length, steps=8, bevel=0.0):
    """A barrel vault standing on z = 0: a half-ellipse [depth] across and
    [rise] high, pulled [length] along x."""
    return along_x(arc(depth / 2, rise, steps), length, bevel=bevel)


def tilted(geometry, about, angle):
    """[geometry] turned [angle] radians around the x axis through the point
    [about] (y, z)."""
    y, z = about
    return geometry.transform((0, -y, -z)).transform(rotation=(angle, 0, 0)).transform((0, y, z))


def collar(radius, width, height, sides=16, smooth=False):
    """A flat ring on z = 0: [width] wide, [height] high, [radius] outside."""
    inner = radius - width
    return sweep.lathe([(inner, 0.0), (radius, 0.0), (radius, height), (inner, height),
                        (inner, 0.0)], sides=sides, smooth=smooth)


def jagged(rng, sides, radius, wobble):
    """The outline of a broken slab: [sides] points round a circle of
    [radius], each pulled in or out by up to [wobble] of it, counter-clockwise."""
    return [(radius * math.cos(a) * (1 + rng.uniform(-wobble, wobble)),
             radius * math.sin(a) * (1 + rng.uniform(-wobble, wobble)))
            for a in (2 * math.pi * (k + rng.uniform(-0.2, 0.2)) / sides for k in range(sides))]
