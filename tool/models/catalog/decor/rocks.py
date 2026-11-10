"""Rocks: rounded boulders with fractures, flat broken slabs, pebbles."""

import math

from mathutils import Vector

from catalog import colors
from workshop import noise, shapes
from workshop.colors import mix, scale, vary


def boulder(rng, size):
    seed = rng.randrange(1000)
    rock = shapes.sphere(1.0, subdivisions=3 if size > 0.32 else 2)
    rock.sharp_angle = math.radians(55)
    stretch = Vector((1 + rng.uniform(-0.15, 0.3), 1 + rng.uniform(-0.15, 0.15),
                      rng.uniform(0.5, 0.85)))

    def bump(p):
        crack = noise.cracks(p, seed, 1.6, 0.25)
        return p.normalized() * (0.22 * noise.fbm(p * 1.3, seed) - 0.12 * crack)

    rock.displace(bump)
    rock.verts = [Vector((v.x * stretch.x, v.y * stretch.y, v.z * stretch.z)) for v in rock.verts]
    shapes.flatten_below(rock, -0.25 * stretch.z, 0.2)
    rock.transform((0, 0, 0.18 * stretch.z * size), scale=size)
    return [(rock, "rock", rock_paint(rng, seed))]


def slab(rng, size):
    """A flat broken stone, a little tilted."""
    sides = rng.randrange(5, 8)
    outline = [(math.cos(a) * r, math.sin(a) * r) for a, r in
               ((2 * math.pi * k / sides + rng.uniform(-0.25, 0.25), rng.uniform(0.7, 1.0))
                for k in range(sides))]
    stone = shapes.prism(outline, rng.uniform(0.18, 0.3), bevel=0.05, segments=1)
    stone.transform((0, 0, -0.08), (rng.uniform(-0.12, 0.12), rng.uniform(-0.12, 0.12), 0),
                    scale=size)
    return [(stone, "rock", rock_paint(rng, rng.randrange(1000)))]


def pebbles(rng, size, count=4):
    parts = []
    for _ in range(count):
        a, r = rng.uniform(0, 2 * math.pi), rng.uniform(0.2, 1.0) * size
        pebble = shapes.sphere(rng.uniform(0.05, 0.11) * size * 2, subdivisions=1)
        pebble.sharp_angle = math.radians(60)
        pebble.transform((math.cos(a) * r, math.sin(a) * r, 0.02), scale=(1, 0.8, 0.55))
        parts.append((pebble, "rock", rock_paint(rng, rng.randrange(1000))))
    return parts


def rock_paint(rng, seed):
    base = vary(mix(colors.BASALT_DEEP, colors.SLATE, rng.random()), rng, 0.2)

    def paint(p, normal):
        mottle = 1 + 0.25 * noise.fbm(p * 5, seed, octaves=2)
        color = scale(base, mottle)
        dust = max(0.0, normal.z - 0.7) * 2.0
        return mix(color, colors.SEDIMENT, min(dust, 0.35))
    return paint
