"""Fronds of kelp for the map: a stem and leaf blades seen from both sides
(the map's reef material is single-sided, so each blade is doubled), and
glowing spore bulbs. Parts as (geometry, material, paint, uv) in their own
frame, standing on z = 0."""

import math

from mathutils import Vector

from catalog import colors, paints
from catalog.parts import light
from workshop import shapes, sweep
from workshop.colors import mix, scale
from workshop.geometry import Geometry


def two_sided(geometry):
    """[geometry] and its back, on vertices of their own (smooth normals and
    the baked occlusion must not mix the two sides): seen from both sides."""
    back = Geometry(geometry.verts, [tuple(reversed(face)) for face in geometry.faces],
                    sharp_angle=geometry.sharp_angle)
    back.smooth = list(geometry.smooth)
    front = Geometry(geometry.verts, geometry.faces, sharp_angle=geometry.sharp_angle)
    front.smooth = list(geometry.smooth)
    return front.extend(back)


def blade(atlas, rng, start, azimuth, length, width, base, tip, rise=0.3, lift=0.3):
    """A broad blade from [start] outward along [azimuth], arching up by
    [rise] of its length then drooping, [width] across at its widest."""
    out = Vector((math.cos(azimuth), math.sin(azimuth), lift)).normalized()
    path = [Vector(start) + out * length * t + Vector((0, 0, rise * length * math.sin(t * 2.6)))
            for t in (0, 0.3, 0.6, 1.0)]
    side = Vector((-math.sin(azimuth), math.cos(azimuth), 0))
    leaf = two_sided(sweep.ribbon(path, [width * 0.35, width, width * 0.85, width * 0.12], [side] * 4))
    paint = paints.organic(base, tip, rng.randrange(99), variation=0.2, height=max(length, 0.2))
    return [(leaf, "reef", paint, atlas.solid("plain")(leaf))]


def frond(atlas, rng, height, base, tip, leaves=5, spread=0.2):
    """A stem swaying up [height], [leaves] blades along it."""
    phase = rng.uniform(0, 6.28)
    points = [Vector((spread * 0.4 * math.sin(phase + t * 3) * t, spread * 0.4 * math.cos(phase + t * 2) * t,
                      t * height)) for t in (k / 6 for k in range(7))]
    stem = sweep.tube(points, [0.03 - 0.0035 * k for k in range(7)], sides=5)
    paint = paints.organic(scale(base, 0.6), base, rng.randrange(99), height=height)
    parts = [(stem, "reef", paint, atlas.solid("plain")(stem))]
    for k in range(leaves):
        start = points[1 + k * 5 // leaves]
        parts += blade(atlas, rng, start, phase + k * 2.4, rng.uniform(0.7, 1.0) * height * 0.6,
                       0.14, base, tip, rise=0.35)
    return parts


def bulb(atlas, radius, tile="green"):
    """A glowing spore bulb at the origin, a little long."""
    ball = shapes.sphere(radius, subdivisions=1).transform(scale=(1, 1, 1.25))
    return [(ball, *light(atlas, tile))]


def tuft(atlas, rng, height, colour=colors.KELP):
    """A tuft of blades of sea grass."""
    parts = []
    for k in range(rng.randrange(5, 8)):
        a = rng.uniform(0, 2 * math.pi)
        lean = Vector((math.cos(a), math.sin(a), 0)) * rng.uniform(0.05, 0.2) * height
        h = height * rng.uniform(0.6, 1.0)
        path = [lean * t * t + Vector((0, 0, t * h)) for t in (0, 0.33, 0.66, 1)]
        side = Vector((-math.sin(a), math.cos(a), 0))
        blade = two_sided(sweep.ribbon(path, [0.05, 0.045, 0.03, 0.006], [side] * 4))
        parts.append((blade, "reef", paints.organic(scale(colour, 0.6), mix(colour, colors.SPONGE_YELLOW, 0.3), k),
                      atlas.solid("plain")(blade)))
    return parts
