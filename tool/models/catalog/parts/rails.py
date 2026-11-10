"""Railings and ladders: thin bars on a gallery's edge."""

from mathutils import Vector

from catalog import colors
from workshop import shapes, sweep


def railing(atlas, outline, height=0.12, posts_every=1, colour=colors.LIMESTONE):
    """A railing along the closed [outline] of (x, y, z) points: a post at
    every [posts_every] point, a top rail and a middle one."""
    blank = atlas.solid("plain")
    parts = []
    loop = [Vector(p) for p in outline] + [Vector(outline[0])]
    for level in (height, height * 0.5):
        rail = sweep.tube([p + Vector((0, 0, level)) for p in loop], [0.008] * len(loop), sides=4,
                          cap=False)
        parts.append((rail, "hull", colour, blank(rail)))
    for p in loop[:-1:posts_every]:
        post = shapes.box((0.016, 0.016, height), bottom=False).transform(p)
        parts.append((post, "hull", colour, blank(post)))
    return parts


def ladder(atlas, height, width=0.12, colour=colors.LIMESTONE, step=0.07):
    """A ladder up z from the origin, in the plane y = 0."""
    blank = atlas.solid("plain")
    parts = []
    for x in (-width / 2, width / 2):
        side = shapes.box((0.014, 0.014, height), bottom=False).transform((x, 0, 0))
        parts.append((side, "hull", colour, blank(side)))
    for k in range(1, int(height / step)):
        rung = shapes.box((width, 0.01, 0.01), bottom=False).transform((0, 0, k * step))
        parts.append((rung, "hull", colour, blank(rung)))
    return parts
