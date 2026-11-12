"""Parts of the command buildings (laboratory, barracks, and the new works of
the headquarters and the citadel): the colours they share, a collector to
build a building in its own frame and turn it to face the camera, windows,
specimen tanks and banners. Each maker gives (geometry, material, paint, uv)
in its own frame, standing on z = 0, front toward -y."""

import math

from catalog.paints import machined
from catalog.parts import light, place
from workshop import shapes
from workshop.colors import linear
from workshop.geometry import Geometry

# The laboratory is kept clean: scrubbed ceramic panels, teal trim and glass.
CERAMIC = linear("#cfdde6")
CERAMIC_DARK = linear("#8fa7b3")
TEAL_TRIM = linear("#3f9a9a")
TEAL_DARK = linear("#255a63")
# The barracks is armoured: blued steel, crimson cloth and lights.
ARMOR = linear("#8c9db8")
ARMOR_DARK = linear("#5a6a84")
CLOTH = linear("#d2415b")
CLOTH_DARK = linear("#8c2a42")
FACING = math.pi / 4  # the turn that brings the front (-y) to the game's camera


class Collector:
    """Parts gathered in a building's own frame, to be laid in place at once."""

    def __init__(self):
        self.parts = []

    def add(self, geometry, material, paint, uv=None):
        self.parts.append((geometry, material, paint, uv))


def chamfered_rect(width, depth, chamfer):
    """The outline of a rectangle whose corners are cut by [chamfer]."""
    w, d, k = width / 2, depth / 2, chamfer
    return [(-w + k, -d), (w - k, -d), (w, -d + k), (w, d - k), (w - k, d), (-w + k, d),
            (-w, d - k), (-w, -d + k)]


def turned(point, angle=FACING):
    """The (x, y) of [point] turned by [angle] about z."""
    x, y = point[0], point[1]
    return (x * math.cos(angle) - y * math.sin(angle), x * math.sin(angle) + y * math.cos(angle))


def lay(target, collector, turn=0.0, at=(0, 0, 0)):
    """The collected parts turned by [turn] about z and moved to [at], in [target]."""
    place(target, collector.parts, at, (0, 0, turn))


def roof_uv(atlas, box, top="panel", side="strap"):
    """The mapping of a roof slab: its top in [top], its edges in [side]."""
    up, edge = atlas.fit(top)(box), atlas.fit(side)(box)
    return [up[i] if box.face_normal(i).z > 0.9 else edge[i] for i in range(len(box.faces))]


def lamp(atlas, tile, at=(0, 0, 0), radius=0.03):
    """A small glowing gem of the atlas' light [tile] at [at]."""
    return [(shapes.octahedron(radius).transform(at), *light(atlas, tile))]


def window(atlas, width, height, tile="panes_amber"):
    """A lit pane facing -y, centred on x = 0, standing on z = 0."""
    w = width / 2
    pane = Geometry([(-w, 0, 0), (w, 0, 0), (w, 0, height), (-w, 0, height)], [(0, 1, 2, 3)])
    return [(pane, "lamp", (0.3, 0.3, 0.3), atlas.fit(tile)(pane))]


def slab(atlas, size, colour, tile="plate", seed=0, bevel=0.015, soot=0.25, top="plate",
         bottom=False):
    """A bevelled box standing on z = 0, its sides in [tile], its top in [top]."""
    box = shapes.box(size, bevel=bevel, bottom=bottom)
    box.subdivide(0.3)
    side, up = atlas.fit(tile)(box), atlas.fit(top)(box)
    uv = [up[i] if box.face_normal(i).z > 0.9 else side[i] for i in range(len(box.faces))]
    return [(box, "hull", machined(colour, seed, soot=soot), uv)]


def tank(atlas, radius, height, tile="liquid", frame=ARMOR_DARK, seed=0):
    """A column of glowing liquid in a frame: caps, four bars and a ring."""
    column = shapes.cylinder(radius, height, sides=10, smooth=False, bottom=False)
    parts = [(column, "lamp", (0.3, 0.3, 0.3), atlas.fit(tile)(column))]
    for z, h in ((-0.02, 0.05), (height - 0.03, 0.06)):
        cap = shapes.cylinder(radius * 1.18, h, sides=10, bevel=0.008, smooth=False)
        parts.append((cap.transform((0, 0, z)), "hull", machined(frame, seed, soot=0.0),
                      atlas.fit("bolt")(cap)))
    for k in range(4):
        a = math.pi / 4 + k * math.pi / 2
        bar = shapes.box((0.016, 0.016, height), bottom=False)
        parts.append((bar.transform((radius * 1.05 * math.cos(a), radius * 1.05 * math.sin(a), 0)),
                      "hull", frame, atlas.solid("plain")(bar)))
    return parts


def banner(atlas, width, height, colour=CLOTH, pole=None, seed=0):
    """A banner hung from a yard on a pole of height [pole] (None: the yard
    alone), facing -y, its cloth waving; the pole at x = -width / 2 - 0.03."""
    cloth = shapes.box((width, 0.012, height), bottom=True)
    cloth.subdivide(0.1)
    uv = atlas.fit("banner")(cloth)
    cloth.displace(lambda p: (0, 0.03 * math.sin(p.x * 11 + p.z * 5) * (1 - p.z / height * 0.6), 0))
    top = pole or height + 0.06
    parts = [(cloth.transform((0, 0, top - height - 0.04)), "hull", colour, uv)]
    yard = shapes.box((width + 0.08, 0.016, 0.016), bottom=False).transform((0, 0, top - 0.04))
    parts.append((yard, "hull", ARMOR_DARK, atlas.solid("plain")(yard)))
    if pole:
        mast = shapes.cylinder(0.016, pole, sides=6, bottom=False).transform((-width / 2 - 0.04, 0, 0))
        parts.append((mast, "hull", ARMOR_DARK, atlas.solid("plain")(mast)))
    return parts
