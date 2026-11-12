"""The parts the monsters' bodies are made of: a body lofted along a spine
(ellipses of any size), thin membranes and solid fins, rows of spikes and
teeth, and the eyes and lights that every monster lights itself with. Each
gives a workshop Geometry in the model's own frame: Blender's, Z up, the
creature facing +Y."""

import math

import bpy  # noqa: F401, loads mathutils
from mathutils import Matrix, Vector

from workshop import shapes, sweep
from workshop.geometry import Geometry

WHITE = (1.0, 1.0, 1.0)


def loft(spine, widths, heights, sides=8, caps=(True, True), lift=None):
    """A body along the points of [spine]: at each, an ellipse [widths] (half,
    across) by [heights] (half, up) wide, raised by [lift] when given. Its
    ends are closed by a point just past the first and last ring when [caps].
    Soft shaded: a living thing."""
    geometry, rings = Geometry(), []
    path = sweep.frames(spine)
    for i, (point, (_, side, up)) in enumerate(zip(spine, path)):
        rings.append(len(geometry.verts))
        raised = Vector((0, 0, lift[i])) if lift else Vector()
        for k in range(sides):
            a = 2 * math.pi * k / sides
            geometry.verts.append(Vector(point) + raised + side * (math.cos(a) * widths[i])
                                  + up * (math.sin(a) * heights[i]))
    for r in range(len(spine) - 1):
        for k in range(sides):
            j = (k + 1) % sides
            geometry.faces.append((rings[r] + k, rings[r] + j, rings[r + 1] + j, rings[r + 1] + k))
    for end, flip in ((0, True), (-1, False)):
        if caps[0 if end == 0 else 1]:
            tip = len(geometry.verts)
            reach = max(widths[end], heights[end]) * 0.55
            tangent = path[end][0] * (-1 if end == 0 else 1)
            raised = Vector((0, 0, lift[end])) if lift else Vector()
            geometry.verts.append(Vector(spine[end]) + raised + tangent * reach)
            for k in range(sides):
                j = (k + 1) % sides
                a, b = rings[end] + k, rings[end] + j
                geometry.faces.append((b, a, tip) if flip else (a, b, tip))
    geometry.smooth = [True] * len(geometry.faces)
    geometry.sharp_angle = sweep.ORGANIC
    return geometry


def membrane(points):
    """A flat polygon through [points], for a thin fin or a web: one face,
    drawn from both sides by the membrane material."""
    return Geometry(points, [range(len(points))])


def fin(outline, thickness):
    """A solid fin: the polygon [outline] of (y, z) points, along the creature
    and up, given [thickness] across it (x), centred on the plane x = 0."""
    slab = shapes.prism(outline, thickness).transform((0, 0, -thickness / 2))
    return slab.apply(Matrix(((0, 0, 1, 0), (1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 0, 1))))


def spikes(bases, tips, radius, sides=4):
    """One cone from each of [bases] to each of [tips], [radius] wide at its
    base: teeth, claws, thorns."""
    geometry = Geometry()
    for base, tip in zip(bases, tips):
        geometry.extend(sweep.tube([base, tip], [radius, radius * 0.12], sides=sides))
    return geometry


def eye(atlas, tile, centre, radius, toe=0.0, flat=0.6):
    """A glowing eye, a bulging disc that looks along +Y, then turned [toe]
    degrees outward and put at [centre]; its geometry and its mapping, the
    tile [tile] of [atlas] (an eye with its slit) seen head on."""
    ball = shapes.sphere(radius, subdivisions=1).transform(scale=(1.0, flat, 1.0))
    uv = atlas.planar(tile, (1, 0, 0), (0, 0, 1))(ball)
    side = 1 if centre[0] > 0 else -1
    return ball.transform(centre, rotation=(0, 0, math.radians(-side * toe))), uv


def add_eyes(model, group, tile, centre, radius, bone, toe=25.0, flat=0.6):
    """The two eyes of [group], the right one at [centre] and the left its
    mirror, in the lamp material, bound to [bone]."""
    for side in (1, -1):
        place = (centre[0] * side, centre[1], centre[2])
        ball, uv = eye(model.atlas, tile, place, radius, toe, flat)
        model.add(group, ball, "lamp", WHITE, uv=uv, bone=bone)


def glow(model, group, light, geometry, bone):
    """[geometry] lit in the plain [light] ('acid', 'ember'...) of the atlas."""
    model.add(group, geometry, "lamp", WHITE, uv=model.atlas.solid(light), bone=bone)


def curve(values, samples):
    """[samples] values along a smooth Catmull-Rom curve through [values]
    (numbers, or points of equal length), from the first to the last: the
    rough polyline of a tentacle's bones turned into its soft path."""
    rows = [v if isinstance(v, (tuple, list)) else (v,) for v in values]
    padded = [rows[0], *rows, rows[-1]]
    found = []
    for s in range(samples):
        at = (len(rows) - 1) * s / (samples - 1)
        i = min(int(at), len(rows) - 2)
        t = at - i
        a, b, c, d = padded[i:i + 4]
        found.append(tuple(0.5 * (2 * q + (r - p) * t + (2 * p - 5 * q + 4 * r - u) * t * t
                                  + (3 * q - p - 3 * r + u) * t ** 3)
                           for p, q, r, u in zip(a, b, c, d)))
    return found if isinstance(values[0], (tuple, list)) else [row[0] for row in found]


def dots(points, radius):
    """A cluster of small lit beads at [points]: photophores, sucker rims."""
    geometry = Geometry()
    for point in points:
        geometry.extend(shapes.octahedron(radius).transform(point))
    return geometry
