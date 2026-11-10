"""The keep's body: a battered plinth, the octagonal hull with its corner
ribs, riveted straps and portholes, and the deck lights on the plinth."""

import math

from catalog import colors
from catalog.paints import machined
from catalog.parts import Into, hatches, light, place, sides_and_top
from workshop import shapes

SIDES, PHASE = 8, math.pi / 8  # flats facing the four avenues and the diagonals
PLINTH = (1.24, 0.2)  # radius at its foot, height
HULL = (1.0, 0.93, 0.2, 1.15)  # radius at its foot and top, from z to z
HEX = math.cos(math.pi / SIDES)  # a flat's distance over the radius


def radius_at(z):
    low, high, bottom, top = HULL
    return low + (high - low) * (z - bottom) / (top - bottom)


def facing(angle, distance, z):
    """Location and turn of a part facing out at [angle] on a flat."""
    return ((distance * math.cos(angle), distance * math.sin(angle), z), (0, 0, angle + math.pi / 2))


def keep(model, group):
    atlas, into = model.atlas, Into(model, group)
    radius, height = PLINTH
    plinth = shapes.prism(shapes.polygon(SIDES, radius, PHASE), height, bevel=0.025, top=0.95,
                          bottom=False).subdivide(0.3)
    into.add(plinth, "hull", machined(colors.HULL_DARK, 1),
             sides_and_top(atlas, plinth, "plate_wide", "tread"))
    strip = shapes.prism(shapes.polygon(SIDES, radius * 0.955 + 0.004, PHASE), 0.018, bottom=False)
    strip.faces = [f for i, f in enumerate(strip.faces) if abs(strip.face_normal(i).z) < 0.5]
    strip.smooth = [False] * len(strip.faces)
    into.add(strip.transform((0, 0, height - 0.03)), *light(atlas, "cyan"))
    low, high, bottom, top = HULL
    hull = shapes.prism(shapes.polygon(SIDES, low, PHASE), top - bottom, bevel=0.02, top=high / low,
                        bottom=False).transform((0, 0, bottom)).subdivide(0.22)
    into.add(hull, "hull", machined(colors.HULL, 2, height=0.8), atlas.fit("plate_tall"))
    for z, h in ((bottom, 0.08), (top - 0.09, 0.09)):
        r = radius_at(z) + 0.02
        band = shapes.prism(shapes.polygon(SIDES, r, PHASE), h, top=radius_at(z + h) / radius_at(z),
                            bottom=False).transform((0, 0, z))
        into.add(band, "hull", machined(colors.TRIM, 3, soot=0.0), atlas.fit("strap"))
    for k in range(SIDES):
        a = PHASE + 2 * math.pi * k / SIDES
        rib = shapes.box((0.08, 0.07, top - bottom + 0.06), bevel=0.012, bottom=False)
        rib.transform((0, 0, 0), (-0.06, 0, 0))
        place(into, [(rib, "hull", machined(colors.HULL_DARK, 4 + k), atlas.fit("plate_tall")(rib))],
              (radius_at(0.5) * math.cos(a), radius_at(0.5) * math.sin(a), bottom - 0.02),
              (0, 0, a + math.pi / 2))
        lamp = shapes.octahedron(0.035).transform((0, 0, 0.03))
        post = shapes.cylinder(0.03, 0.05, sides=6, bottom=False)
        spot = (radius * 0.97 * math.cos(a), radius * 0.97 * math.sin(a), height)
        place(into, [(post, "hull", colors.METAL_DARK, None), (lamp, *light(atlas, "cyan"))],
              (spot[0] * 0.98, spot[1] * 0.98, height * 0.95))
    _portholes(into, atlas)


def _portholes(into, atlas):
    for k in range(SIDES):
        angle = 2 * math.pi * k / SIDES
        if k % 2:  # the diagonals: the crew's quarters, two decks of windows
            for offset, z in ((-0.17, 0.5), (0.17, 0.5), (-0.17, 0.86), (0.17, 0.86)):
                location, turn = facing(angle, radius_at(z) * HEX + 0.005, z)
                shift = (-math.sin(angle) * offset, math.cos(angle) * offset, 0)
                at = tuple(c + s for c, s in zip(location, shift))
                place(into, hatches.porthole(atlas, 0.075, seed=k), at, turn)
        else:  # above each airlock's vault
            location, turn = facing(angle, radius_at(0.9) * HEX + 0.005, 0.9)
            place(into, hatches.porthole(atlas, 0.06, "porthole_cyan", seed=k), location, turn)

