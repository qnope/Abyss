"""The pieces of a monster's lair: teeth, tusks, horns and a mouth, the dark
opening of a cavern ringed by fangs. Each maker gives parts as (geometry,
material, paint, uv) in its own frame; a mouth lies in the plane z = 0 facing
+z, so a lair tilts it onto the slope it opens in."""

import math

from mathutils import Vector

from catalog import colors
from workshop import shapes, sweep
from workshop.colors import linear

IVORY = linear("#e8e0c8")
BONE = linear("#cfc6ab")
DARK = (0.012, 0.01, 0.015)


def point_along(geometry, direction, at=(0, 0, 0)):
    """A shape built along +z turned to point along [direction], its foot at [at]."""
    matrix = Vector(direction).normalized().to_track_quat("Z", "Y").to_matrix().to_4x4()
    return geometry.apply(matrix).transform(at)


def fang(atlas, length, radius, curl=0.0, colour=IVORY, sides=6):
    """A tooth up +z from its root, curling by [curl] of its length."""
    cone = sweep.lathe([(radius, -0.02), (radius * 0.85, length * 0.3), (radius * 0.4, length * 0.72),
                        (0.0, length)], sides=sides, smooth=False)
    cone.displace(lambda p: (curl * length * (p.z / length) ** 2, 0, 0))
    return [(cone, "hull", colour, atlas.solid("plain")(cone))]


def tusk(atlas, length, radius, bend, side, colour=IVORY):
    """A long curved tusk from the origin: it rises along +z, bends toward
    +y by [bend] and curls inward (toward x = 0 on the side [side])."""
    points = [Vector((-side * 0.35 * length * t * t, bend * length * t * t, length * t))
              for t in (0, 0.25, 0.5, 0.75, 1.0)]
    body = sweep.tube(points, [radius, radius * 0.85, radius * 0.65, radius * 0.4, radius * 0.1], sides=6)
    return [(body, "hull", colour, atlas.solid("plain")(body))]


def horn(atlas, length, radius, colour=BONE):
    """A short, straight, ringed horn up +z."""
    body = sweep.lathe([(radius, -0.02), (radius * 0.8, length * 0.35), (radius * 0.5, length * 0.7),
                        (0.0, length)], sides=6, smooth=False)
    return [(body, "hull", colour, atlas.solid("plain")(body))]


def rim_spots(rx, ry, count, start, end):
    """(x, y, angle) of [count] spots on the ellipse (rx, ry), angles in degrees."""
    spots = []
    for k in range(count):
        a = math.radians(start + (end - start) * (k + 0.5) / count)
        spots.append((rx * math.cos(a), ry * math.sin(a), a))
    return spots


def jaws(atlas, rng, rx, ry, upper, lower, size):
    """Rows of fangs round a mouth of radii [rx], [ry]: [upper] above and
    [lower] below, [size] long, pointing in and out of the plane."""
    parts = []
    for count, start, end, sign, scale_ in ((upper, 8, 172, -1, 1.0), (lower, 200, 340, 1, 0.7)):
        for x, y, a in rim_spots(rx, ry, count, start, end):
            fangs = fang(atlas, size * scale_ * rng.uniform(0.75, 1.15), size * 0.2 * scale_, curl=0.25 * -sign)
            inward = Vector((-math.cos(a) * 0.55, -math.sin(a) * 0.55, 0.7))
            for g, *_ in fangs:
                point_along(g, inward, (x, y, 0.0))
            parts += fangs
    return parts


def cavity(atlas, rx, ry, glow=None):
    """The dark mouth: a disc of black, a smaller disc of [glow] (a lamp tile)
    deep in it, two eyes of the same light."""
    hole = shapes.cylinder(1.0, 0.02, sides=20, smooth=False).transform((0, 0, 0), scale=(rx, ry, 1))
    parts = [(hole, "hull", DARK, atlas.solid("plain")(hole))]
    if glow:
        back = shapes.cylinder(1.0, 0.02, sides=16, smooth=False).transform(
            (0, -ry * 0.1, 0.02), scale=(rx * 0.6, ry * 0.5, 1))
        parts.append((back, "lamp", colors.LAMP, atlas.solid(glow)(back)))
    return parts


def eyes(atlas, rx, ry, tile="red", size=0.04):
    """Two slit eyes of light in the dark of a mouth."""
    parts = []
    for side in (-1, 1):
        eye = shapes.octahedron(size).transform((side * rx * 0.38, ry * 0.12, 0.035), (0, 0, side * 0.5),
                                                scale=(1.5, 0.6, 0.6))
        parts.append((eye, "lamp", colors.LAMP, atlas.solid(tile)(eye)))
    return parts


def lip(atlas, rx, ry, colour, thickness=0.05):
    """The rock lip round a mouth: a lumpy ring of radii a little over [rx], [ry]."""
    n = 24
    path = [Vector((rx * 1.1 * math.cos(2 * math.pi * k / n), ry * 1.1 * math.sin(2 * math.pi * k / n),
                    0.0)) for k in range(n)]
    ring = sweep.tube(path + [path[0]], [thickness * (1 + 0.3 * math.sin(k * 2.1)) for k in range(n + 1)],
                      sides=6, cap=False)
    return [(ring, "reef", colour, atlas.tiled("coral", 0.4)(ring))]


def bone(atlas, length, colour=BONE):
    """A bone lying on z = 0 along x: a shaft and a knob at each end."""
    radius = length * 0.09
    shaft = shapes.cylinder(radius, length, sides=6, smooth=False).transform((-length / 2, 0, radius),
                                                                              (0, math.pi / 2, 0))
    parts = [(shaft, "hull", colour, atlas.solid("plain")(shaft))]
    for end in (-1, 1):
        knob = shapes.sphere(radius * 1.6, subdivisions=1).transform((end * length / 2, 0, radius * 1.4))
        parts.append((knob, "hull", colour, atlas.solid("plain")(knob)))
    return parts
