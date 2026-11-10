"""An airlock toward each avenue: a vaulted vestibule out of the hull, its
door at the end, a vent on each flank, a lamp over the threshold."""

import math

from mathutils import Vector

from catalog import colors
from catalog.headquarters.keep import HEX, PLINTH, facing, radius_at
from catalog.paints import machined
from catalog.parts import Into, hatches, light, place, props
from workshop import shapes
from workshop.geometry import Geometry

WIDTH, HEIGHT = 0.56, 0.5  # the vestibule's walls; its vault rises above
OUT = 1.36  # how far its door stands from the centre


def airlocks(model, group):
    atlas, into = model.atlas, Into(model, group)
    for k in range(4):
        angle = k * math.pi / 2
        inner = radius_at(0.3) * HEX - 0.08
        depth = OUT - inner
        parts = _vestibule(atlas, depth, k)
        location, turn = facing(angle, OUT, PLINTH[1] - 0.02)
        place(into, parts, location, turn)
        door = hatches.door(atlas, 0.3, 0.38, colour=colors.STONE, seed=k)
        place(into, door, facing(angle, OUT + 0.005, PLINTH[1] - 0.02)[0], turn)
        _approach(into, atlas, angle)


def _vestibule(atlas, depth, seed):
    """Walls, vault and vents, the door's plane at y = 0, reaching back
    (+y) by [depth] into the hull."""
    walls = shapes.box((WIDTH, depth, HEIGHT), bevel=0.02, bottom=False).transform((0, depth / 2, 0))
    walls.subdivide(0.2)
    vault = _vault(WIDTH / 2 + 0.02, depth + 0.02).transform((0, depth / 2, HEIGHT - 0.02))
    rim = _vault(WIDTH / 2 + 0.05, 0.06).transform((0, 0.02, HEIGHT - 0.03))
    paint = machined(colors.HULL, 10 + seed, soot=0.3)
    parts = [(walls, "hull", paint, atlas.fit("plate_wide")(walls)),
             (vault, "hull", machined(colors.HULL, 11 + seed, soot=0.0),
              atlas.tiled("weathered", 0.5)(vault)),
             (rim, "hull", machined(colors.TRIM, 12, soot=0.0), atlas.fit("strap")(rim))]
    parts += props.badge(atlas, 0.075)
    parts[-1][0].transform((0, -0.03, HEIGHT + 0.06))
    for side in (-1, 1):
        vent = shapes.box((0.025, 0.2, 0.16), bevel=0.006).transform((side * WIDTH / 2, depth * 0.45, 0.2))
        vent_uv = atlas.fit("vent")(vent)
        parts.append((vent, "hull", colors.STONE_WORN, vent_uv))
        beacon = shapes.octahedron(0.026).transform((side * (WIDTH / 2 + 0.035), -0.02, HEIGHT - 0.05))
        parts.append((beacon, *light(atlas, "cyan")))
    return parts


def _vault(radius, length, sides=8):
    """A half cylinder along y, [length] long, standing on z = 0."""
    geometry = Geometry()
    for y in (-length / 2, length / 2):
        for k in range(sides + 1):
            a = math.pi * k / sides
            geometry.verts.append((radius * math.cos(a), y, radius * 0.5 * math.sin(a)))
    geometry.verts = [Vector(v) for v in geometry.verts]
    n = sides + 1
    geometry.faces = [(k + 1, k, n + k, n + k + 1) for k in range(sides)]
    cap = [(list(range(n)), True), (list(range(n, 2 * n))[::-1], True)]
    geometry.faces += [tuple(face) for face, _ in cap]
    geometry.smooth = [True] * sides + [False, False]
    geometry.sharp_angle = math.radians(40)
    return geometry


def _approach(into, atlas, angle):
    """A bollard light at each side of the threshold."""
    for side in (-1, 1):
        offset = side * (WIDTH / 2 + 0.1)
        x = (OUT + 0.06) * math.cos(angle) - math.sin(angle) * offset
        y = (OUT + 0.06) * math.sin(angle) + math.cos(angle) * offset
        post = shapes.cylinder(0.028, 0.12, sides=6, top_radius=0.022, bottom=False)
        cap = shapes.cylinder(0.03, 0.025, sides=6).transform((0, 0, 0.12))
        place(into, [(post, "hull", machined(colors.METAL_DARK, 20, soot=0.0), atlas.fit("plate_tall")(post)),
                     (cap, *light(atlas, "amber"))], (x, y, 0.0))
