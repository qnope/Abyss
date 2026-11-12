"""Glazed roofs: a barrel vault and a dome of lit panes between ribs. The
panes are the lamp material mapped on every face with its own tile, so a
greenhouse glows from within and its ribs stay dark."""

import math

from mathutils import Vector

from catalog import colors
from catalog.paints import machined
from workshop import shapes, sweep
from workshop.geometry import Geometry

_CORNERS = {3: [(0, 0), (1, 0), (0.5, 1)], 4: [(0, 0), (1, 0), (1, 1), (0, 1)]}


def per_face(atlas, tile):
    """A mapping of the whole tile on each quad (or triangle) of a geometry."""
    u0, v0, u1, v1 = atlas.rect(tile)
    return lambda geometry: [[(u0 + s * (u1 - u0), v0 + t * (v1 - v0)) for s, t in _CORNERS[len(face)]]
                             for face in geometry.faces]


def vault(atlas, length, radius, height, facets=8, sections=5, tile="glasshouse", seed=0):
    """A barrel vault along x on z = 0, [length] long, [radius] each side of
    the axis and [height] high: its lit panes, ribs, a ridge beam, sills and
    the plates of its two ends. Gives (parts, ends): the plates apart, so
    that one can be pierced by a door."""
    xs = [-length / 2 + length * i / sections for i in range(sections + 1)]
    arc = [(radius * math.cos(math.pi * j / facets), height * math.sin(math.pi * j / facets))
           for j in range(facets + 1)]
    skin, mapping, row = Geometry(), [], facets + 1
    for x in xs:
        skin.verts += [Vector((x, y, z)) for y, z in arc]
    u0, v0, u1, v1 = atlas.rect(tile)
    for i in range(sections):
        for j in range(facets):
            skin.faces.append((i * row + j, i * row + j + 1, (i + 1) * row + j + 1, (i + 1) * row + j))
            mapping.append([(u0, v0), (u0, v1), (u1, v1), (u1, v0)])
    skin.smooth = [False] * len(skin.faces)
    parts = [(skin, "lamp", colors.LAMP, mapping)]
    steel = machined(colors.HULL, seed, soot=0.0)
    for x in xs:
        rib = sweep.tube([(x, y * 1.03, z * 1.03 + 0.004) for y, z in arc], [0.016] * row, sides=4,
                         cap=False)
        parts.append((rib, "hull", steel, atlas.solid("plain")(rib)))
    ridge = sweep.tube([(xs[0], 0, height * 1.03), (xs[-1], 0, height * 1.03)], [0.02, 0.02], sides=4,
                       cap=False)
    parts.append((ridge, "hull", steel, atlas.solid("plain")(ridge)))
    for side in (-1, 1):
        sill = shapes.box((length + 0.04, 0.045, 0.05), bevel=0.008, bottom=False)
        sill.transform((0, side * (radius + 0.005), 0))
        parts.append((sill, "hull", machined(colors.HULL_DARK, seed + 1), atlas.fit("strap")(sill)))
    return parts, [_end(atlas, x, arc, seed + 2) for x in (xs[0], xs[-1])]


def _end(atlas, x, arc, seed):
    """The plate closing the vault at x, facing outwards along the x axis."""
    plate = Geometry([(x, y, z) for y, z in arc], [tuple(range(len(arc)))])
    if plate.face_normal(0).x * x < 0:
        plate.faces = [tuple(reversed(plate.faces[0]))]
    return (plate, "hull", machined(colors.HULL, seed, soot=0.2), atlas.fit("plate")(plate))


def dome(atlas, radius, height, segments=10, rings=3, tile="glasshouse", seed=0):
    """A dome on z = 0: lit panes on rings, meridian ribs, a collar."""
    profile = [(radius * math.cos(math.pi / 2 * k / rings), height * math.sin(math.pi / 2 * k / rings))
               for k in range(rings)] + [(0.0, height)]
    skin = sweep.lathe(profile, sides=segments, smooth=False)
    parts = [(skin, "lamp", colors.LAMP, per_face(atlas, tile)(skin))]
    steel = machined(colors.HULL, seed, soot=0.0)
    for k in range(segments):
        a = 2 * math.pi * k / segments
        out = Vector((math.cos(a), math.sin(a), 0))
        path = [out * (r * 1.03 + 0.004) + Vector((0, 0, z * 1.03)) for r, z in profile]
        rib = sweep.tube(path, [0.014] * len(path), sides=4, cap=False)
        parts.append((rib, "hull", steel, atlas.solid("plain")(rib)))
    collar = shapes.cylinder(radius * 1.04, 0.05, sides=segments, bevel=0.008, bottom=False)
    parts.append((collar, "hull", machined(colors.HULL_DARK, seed + 1), atlas.fit("strap")(collar)))
    return parts


def pane_strip(atlas, size, tile="glasshouse"):
    """A flat lit window facing -y (the front view): its own tile."""
    pane = shapes.box(size, bottom=False)
    pane.faces = [f for i, f in enumerate(pane.faces) if pane.face_normal(i).y < -0.5]
    pane.smooth = [False] * len(pane.faces)
    return [(pane, "lamp", colors.LAMP, atlas.fit(tile)(pane))]
