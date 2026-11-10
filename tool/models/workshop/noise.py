"""Seeded smooth noise for shapes and colours, from Blender's Perlin noise.
Used at build time only: nothing procedural reaches the glb."""

import math

import bpy  # noqa: F401, loads mathutils
from mathutils import Vector, noise


def _offset(seed):
    return Vector((math.fmod(seed * 12.9898, 97.0), math.fmod(seed * 78.233, 89.0),
                   math.fmod(seed * 37.719, 83.0)))


def value(point, seed=0, frequency=1.0):
    """Smooth noise in about [-1, 1] at [point], a different field per [seed]."""
    return noise.noise(Vector(point) * frequency + _offset(seed), noise_basis="PERLIN_NEW") * 1.6


def fbm(point, seed=0, frequency=1.0, octaves=3, gain=0.5):
    """Fractal noise in about [-1, 1]: [octaves] layers, each twice as fine and
    [gain] times as strong as the last."""
    total, weight, norm = 0.0, 1.0, 0.0
    for octave in range(octaves):
        total += weight * value(point, seed + octave * 31, frequency * 2 ** octave)
        norm += weight
        weight *= gain
    return total / norm


def vector(point, seed=0, frequency=1.0):
    """A smooth random offset in about [-1, 1] on each axis."""
    return Vector((value(point, seed, frequency), value(point, seed + 7, frequency),
                   value(point, seed + 13, frequency)))
