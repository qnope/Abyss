"""The lairs of the three difficulties, one grammar: a mound of rock with the
dark mouth of a cavern tilted toward the camera on its front slope, ringed by
fangs, horns on the crown, and, the deeper the lair, more of everything: the
easy one is a small den of coral with a few teeth and a pair of eyes, the
hard one a huge crimson cavern whose jaws glow red between tusks and horns.
The lair does not say which family lives in it."""

import math
from dataclasses import dataclass

from mathutils import Euler, Vector

from catalog import mapkit, paints
from catalog.parts import lair, place
from catalog.parts.deep import swell
from workshop import noise, shapes, sweep
from workshop.colors import scale


@dataclass(frozen=True)
class Lair:
    """What makes a lair grow: [radius] and [height] of the mound, its
    [colour], the mouth's radii and the elevation of its normal (degrees),
    the fangs above and below and their length, the [glow] of its depth (a
    lamp tile or None), the number and length of horns, whether tusks flank
    the mouth, the bones lying before it."""

    radius: float
    height: float
    colour: tuple
    mouth: tuple
    tilt: float
    upper: int
    lower: int
    fang: float
    glow: str | None
    horns: int
    horn: float
    tusks: bool
    bones: int


def profile(spec):
    r, h = spec.radius, spec.height
    return [(r, -0.03), (r * 0.97, 0.03), (r * 0.86, h * 0.34), (r * 0.64, h * 0.68), (r * 0.34, h * 0.92),
            (0.0, h)]


def height_at(points, radius):
    """The mound's height at [radius], from its profile."""
    for (r0, z0), (r1, z1) in zip(points, points[1:]):
        if r1 <= radius <= r0:
            return z1 + (z0 - z1) * (radius - r1) / (r0 - r1)
    return points[-1][1]


def build(model, spec):
    atlas, rng, into = model.atlas, model.rng, mapkit.body(model)
    body = swell(sweep.lathe(profile(spec), sides=18), model.seed, 0.05 + 0.06 * spec.radius, 0.1)
    body.sharp_angle = math.radians(50)
    paint = paints.organic(scale(spec.colour, 0.6), scale(spec.colour, 1.15), model.seed, height=spec.height)
    into.add(body, "reef", paint, atlas.tiled("coral", 0.5)(body))
    _boulders(into, atlas, rng, spec)
    distance = spec.radius * 0.78
    site = (0.0, -distance, height_at(profile(spec), distance))
    turn = (math.pi / 2 - math.radians(spec.tilt), 0, 0)
    rx, ry = spec.mouth
    for parts in (lair.lip(atlas, rx, ry, scale(spec.colour, 0.5)), lair.cavity(atlas, rx, ry, spec.glow),
                  lair.eyes(atlas, rx, ry, "red"), lair.jaws(atlas, rng, rx, ry, spec.upper, spec.lower, spec.fang)):
        place(into, parts, site, turn)
    if spec.tusks:
        for side in (-1, 1):
            at = Vector(site) + Euler(turn).to_matrix() @ Vector((side * rx * 1.15, -ry * 0.5, 0.0))
            place(into, lair.tusk(atlas, ry * 2.0, 0.035, 0.35, side), at, turn)
    _horns(into, atlas, rng, spec)
    _bones(into, atlas, rng, spec)


def _boulders(into, atlas, rng, spec):
    """Rocks of the same stone heaped round the back and sides of the mound's foot."""
    for k in range(7):
        a = math.radians(-20 + 220 * k / 6 + rng.uniform(-8, 8))
        size = spec.radius * rng.uniform(0.2, 0.3)
        rock = shapes.sphere(1.0, subdivisions=2)
        rock.sharp_angle = math.radians(50)
        rock.displace(lambda p: p.normalized() * 0.25 * noise.fbm(p * 1.6, k))
        shapes.flatten_below(rock, -0.1, 0.1)
        rock.transform((0, 0, 0), scale=(size, size * 0.9, size * 0.7))
        rock.transform((spec.radius * 0.86 * math.cos(a), spec.radius * 0.86 * math.sin(a), 0.0),
                       (0, 0, rng.uniform(0, 6.28)))
        shade = scale(spec.colour, rng.uniform(0.55, 0.8))
        into.add(rock, "reef", paints.organic(scale(shade, 0.7), shade, k, height=size),
                 atlas.tiled("coral", 0.4)(rock))


def _horns(into, atlas, rng, spec):
    """Horns round the crown, on the back half of the mound."""
    for k in range(spec.horns):
        a = math.radians(15 + 150 * (k + 0.5) / spec.horns)
        r = spec.radius * rng.uniform(0.3, 0.5)
        parts = lair.horn(atlas, spec.horn * rng.uniform(0.8, 1.15), spec.horn * 0.16)
        for geometry, *_ in parts:
            lair.point_along(geometry, (math.cos(a) * 0.5, math.sin(a) * 0.5, 1.0),
                             (r * math.cos(a), r * math.sin(a), height_at(profile(spec), r) - 0.02))
        place(into, parts)


def _bones(into, atlas, rng, spec):
    """Bones lying on the floor before the mouth."""
    for _ in range(spec.bones):
        a = math.radians(-90 + rng.uniform(-60, 60))
        r = spec.radius * rng.uniform(0.95, 1.15)
        place(into, lair.bone(atlas, rng.uniform(0.1, 0.16)), (r * math.cos(a), r * math.sin(a), 0.02),
              (0, 0, rng.uniform(0, 3.14)))
