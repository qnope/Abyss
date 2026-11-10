"""The walkways: metal gangways from the headquarters to every pad, with
low rails and a dotted line of lights; the four avenues run on over the rim
to a jetty above the abyss."""

import math

from mathutils import Vector

from catalog import colors, paints
from catalog.base_island import layout, outline
from catalog.base_island.layout import WALKWAY_WIDTH, plan
from workshop import shapes
from workshop.colors import vary
from workshop.geometry import Geometry

GROUP = "Island"
TOP = 0.05
RAIL = 0.07


def walkways(model):
    for index, (a, b) in enumerate(layout.WALKWAYS):
        _gangway(model, Vector(plan(*a)), Vector(plan(*b)), index)
    for index, gate in enumerate(layout.GATES):
        start = Vector(plan(*gate))
        q, n, _ = outline.nearest(*(start + _outward(gate) * 0.01))
        end = start + n * (outline.margin(q, n) + 0.35)
        _gangway(model, start, end, 20 + index)
        _jetty(model, end, n, 30 + index)


def _gangway(model, a, b, seed):
    rng = model.rng
    along = b - a
    length, turn = along.length, math.atan2(along.y, along.x)
    count = max(1, round(length / 0.5))
    plates = Geometry()
    for k in range(count):
        size = (length / count - 0.035, WALKWAY_WIDTH - 0.12, TOP + 0.01)
        x = -length / 2 + (k + 0.5) * length / count
        plates.extend(shapes.box(size, bevel=0.012, bottom=False).transform((x, 0, -0.01)))
    rails, lights = Geometry(), Geometry()
    for side in (-1, 1):
        y = side * (WALKWAY_WIDTH / 2 - 0.03)
        rails.extend(shapes.box((length, 0.06, RAIL), bevel=0.015, bottom=False).transform((0, y, 0)))
        for k in range(count):
            x = -length / 2 + (k + 0.5) * length / count
            lights.extend(shapes.box((0.06, 0.03, 0.012), bottom=False).transform((x, y, RAIL - 0.002)))
    middle = (a + b) / 2
    for geometry, material, paint in (
            (plates, "metal", paints.worked(vary(colors.METAL, rng, 0.06), seed, mottle=0.1,
                                            grime=(colors.RUST, 0.2))),
            (rails, "metal", paints.worked(colors.METAL_DARK, seed + 1, edge=1.9)),
            (lights, "glow", colors.GLOW_CYAN)):
        geometry.transform(rotation=(0, 0, turn)).transform((middle.x, middle.y, 0))
        model.add(GROUP, geometry, material, paint)


def _jetty(model, end, n, seed):
    """A landing at the end of an avenue, over the abyss, with two lit bollards."""
    turn = math.atan2(n.y, n.x)
    deck = shapes.prism(shapes.polygon(10, 0.5), TOP + 0.04, bevel=0.015).transform(
        (0, 0, -0.04), scale=(0.7, 1, 1))
    posts, caps = Geometry(), Geometry()
    for side in (-1, 1):
        posts.extend(shapes.cylinder(0.05, 0.28, sides=8, bevel=0.01).transform((0.2, side * 0.36, TOP)))
        caps.extend(shapes.sphere(0.045, 1).transform((0.2, side * 0.36, TOP + 0.31)))
    strut = shapes.box((0.08, 0.3, 0.9), bevel=0.02).transform((0, 0, -0.9), (0, 0.5, 0))
    paint = paints.worked(vary(colors.METAL, model.rng, 0.06), seed)
    for geometry, material, color in ((deck, "metal", paint), (posts, "metal", colors.METAL_DARK),
                                      (caps, "glow", colors.GLOW_CYAN),
                                      (strut, "metal", colors.METAL_DARK)):
        geometry.transform(rotation=(0, 0, turn)).transform((end.x, end.y, 0))
        model.add(GROUP, geometry, material, color)


def _outward(gate):
    u, v = gate
    return Vector((1 if u == layout.SIZE else -1 if u == 0 else 0,
                   -1 if v == layout.SIZE else 1 if v == 0 else 0))
