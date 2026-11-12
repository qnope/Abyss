"""Tier 1 of the pressure capsule: an octagonal plinth with a round dais ringed
by cyan lamps, four legs cradling the sphere of the pressure hull (white
above, steel blue below, bolted at the equator), its big cyan viewport toward
the camera, a hatch on top and two yellow gas bottles piped to the hull."""

import math

from catalog import colors
from catalog.paints import machined
from catalog.parts import Into, hatches, place, plumbing, sides_and_top
from catalog.parts.deep import STEEL, STEEL_DEEP, WHITE, YELLOW, around, beam, hatch, lamp
from catalog.pressure_capsule import layout
from catalog.pressure_capsule.layout import CENTRE, FRONT, RADIUS, on_sphere
from workshop import noise, shapes, sweep
from workshop.colors import scale

BOTTLES = ((math.radians(-22), 0.84), (math.radians(-68), 0.84))


def tier1(model, group):
    atlas, into = model.atlas, Into(model, group)
    _plinth(into, atlas)
    _sphere(into, atlas)
    _legs(into, atlas)
    _fittings(into, atlas)
    _bottles(into, atlas)


def _plinth(into, atlas):
    radius, height = layout.PLINTH
    plinth = shapes.prism(shapes.polygon(8, radius, math.pi / 8), height, bevel=0.025, top=0.96,
                          bottom=False).subdivide(0.3)
    into.add(plinth, "hull", machined(STEEL_DEEP, 1, soot=0.5, height=0.2),
             sides_and_top(atlas, plinth, "plate_wide", "tread"))
    dais = shapes.cylinder(0.76, 0.06, sides=16, top_radius=0.72, bevel=0.01, smooth=False)
    place(into, [(dais, "hull", machined(STEEL, 2, soot=0.0), sides_and_top(atlas, dais, "strap", "plate"))],
          (0, 0, height))
    for x, y, _ in around(8, 0.78, phase=math.pi / 8):
        place(into, lamp(atlas, "cyan", 0.03), (x, y, height + 0.07))


def _shell(low, high, steps, colour, seed):
    """The part of the sphere between two latitudes (degrees), as a lathe."""
    profile = [(RADIUS * math.cos(math.radians(d)), CENTRE + RADIUS * math.sin(math.radians(d)))
               for d in (low + (high - low) * k / steps for k in range(steps + 1))]
    shell = sweep.lathe(profile, sides=24)
    shell.sharp_angle = math.radians(50)

    def paint(p, normal):
        sector = 0.94 + 0.06 * math.cos(3 * math.atan2(p.y, p.x))
        return scale(colour, sector * (1 + 0.07 * noise.fbm(p * 3, seed, octaves=2)))
    return shell, paint


def _sphere(into, atlas):
    for (low, high, steps), colour, seed in (((-90, 0, 8), STEEL, 3), ((0, 90, 8), WHITE, 4)):
        shell, paint = _shell(low, high, steps, colour, seed)
        into.add(shell, "hull", paint, atlas.tiled("plates", 0.7)(shell))
    band = shapes.cylinder(RADIUS + 0.018, 0.1, sides=24, smooth=False).transform((0, 0, CENTRE - 0.05))
    into.add(band, "hull", machined(STEEL_DEEP, 5, soot=0.0), atlas.fit("strap")(band))


def _legs(into, atlas):
    for a in layout.LEGS:
        foot = (0.78 * math.cos(a), 0.78 * math.sin(a), layout.PLINTH[1] + 0.05)
        head = (0.5 * math.cos(a), 0.5 * math.sin(a), 0.78)
        place(into, beam(atlas, foot, head, 0.1, STEEL_DEEP, 10, depth=0.12))
        pad = shapes.box((0.16, 0.2, 0.05), bevel=0.01)
        place(into, [(pad, "hull", machined(STEEL, 11, soot=0.0), atlas.fit("plate")(pad))],
              (0.47 * math.cos(a), 0.47 * math.sin(a), 0.78), (0, 0, a))


def _fittings(into, atlas):
    place(into, hatches.porthole(atlas, 0.16, "porthole_cyan", seed=1),
          on_sphere(FRONT, math.radians(4), RADIUS - 0.012), (0, 0, FRONT + math.pi / 2))
    top = CENTRE + RADIUS
    collar = shapes.cylinder(0.18, 0.08, sides=12, top_radius=0.16, bevel=0.01, smooth=False)
    place(into, [(collar, "hull", machined(STEEL_DEEP, 6, soot=0.0), atlas.fit("bolt")(collar))],
          (0, 0, top - 0.04))
    place(into, hatch(atlas, 0.14, WHITE, 7), (0, 0, top + 0.04))


def _bottles(into, atlas):
    for k, (a, r) in enumerate(BOTTLES):
        x, y = r * math.cos(a), r * math.sin(a)
        body = shapes.cylinder(0.09, 0.5, sides=12, top_radius=0.085, bevel=0.012, smooth=True)
        dome = shapes.sphere(0.085, subdivisions=1).transform((0, 0, 0.5), scale=(1, 1, 0.7))
        cap = shapes.cylinder(0.03, 0.06, sides=8, bottom=False).transform((0, 0, 0.54))
        band = shapes.cylinder(0.094, 0.05, sides=12, smooth=False).transform((0, 0, 0.3))
        place(into, [(body, "hull", machined(YELLOW, 20 + k, soot=0.3, height=0.2), atlas.tiled("plates", 0.5)(body)),
                     (dome, "hull", machined(YELLOW, 22 + k, soot=0.0), atlas.solid("plain")(dome)),
                     (cap, "hull", colors.METAL_DARK, None),
                     (band, "hull", WHITE, atlas.fit("hazard")(band))], (x, y, layout.PLINTH[1]))
        place(into, plumbing.pipe(atlas, [(x, y, 0.72), (x * 0.8, y * 0.8, 0.84), on_sphere(a, -0.35, RADIUS - 0.02)],
                                  0.025, colors.PIPE, flanges=1, seed=k))
