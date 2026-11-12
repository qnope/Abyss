"""The shapes the units are made of, placed by points rather than by
transforms: a limb or a rod from one point to another, a ball, a slab. Each
gives a workshop Geometry in the figure's frame (Z up, facing +Y)."""

import math

import bpy  # noqa: F401, loads mathutils
from mathutils import Matrix, Vector

from workshop import shapes, sweep


def limb(a, b, ra, rb, sides=7):
    """A tube from [a] to [b], [ra] wide at the start (open: it grows from a
    joint) and [rb] at the end."""
    return sweep.tube([a, b], [ra, rb], sides=sides)


def ball(centre, radius, scale=(1, 1, 1), subdivisions=1):
    """A sphere (20 triangles at 1, 80 at 2) stretched by [scale]."""
    return shapes.sphere(radius, subdivisions).transform(centre, scale=scale)


def slab(centre, size, bevel=0.015, rotation=(0, 0, 0)):
    """A bevelled box of [size] (x, y, z) centred on [centre], turned by
    [rotation] (radians, about its own centre)."""
    box = shapes.box(size, bevel=bevel, bottom=True)
    box.transform((0, 0, -size[2] / 2))
    return box.transform(centre, rotation)


def rod(a, b, radius, top_radius=None, sides=6, smooth=True):
    """A cylinder from [a] to [b], [radius] at a and [top_radius] at b."""
    start, end = Vector(a), Vector(b)
    length = (end - start).length
    cylinder = shapes.cylinder(radius, length, sides, top_radius, smooth=smooth)
    turn = Vector((0, 0, 1)).rotation_difference((end - start).normalized()).to_matrix().to_4x4()
    return cylinder.apply(Matrix.Translation(start) @ turn)


def cone(base, tip, radius, sides=6):
    """A pointed cone from the circle of [radius] at [base] to [tip]."""
    return rod(base, tip, radius, top_radius=0.001, sides=sides)


def plate_prism(outline, thickness, centre=(0, 0, 0), rotation=(0, 0, 0), bevel=0.0):
    """The polygon [outline] (x, y), thickened along z and centred on [centre]:
    a fin, a blade, a shield's face."""
    solid = shapes.prism(outline, thickness, bevel)
    solid.transform((0, 0, -thickness / 2))
    return solid.transform(centre, rotation)


def torso(radius_low, radius_high, height, z, depth=0.8, sides=8):
    """A barrel of a chest, from [z] up [height], flattened front to back by
    [depth]."""
    barrel = shapes.cylinder(radius_low, height, sides, radius_high, smooth=True)
    return barrel.transform((0, 0, z), scale=(1, depth, 1))


def turned(geometry, degrees, about="x"):
    """[geometry] turned [degrees] about an axis through the origin."""
    angle = math.radians(degrees)
    return geometry.transform(rotation=tuple(angle if a == about else 0.0 for a in "xyz"))
