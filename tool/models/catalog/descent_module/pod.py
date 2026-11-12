"""The descent pod, the vehicle that carries the units down: a capsule hanging
over the well on its cables. Tier 1 is its hull with ports and a hatch, tier 2
the fins and the clamp arms of the gantry that hold it, tier 3 its armour
bands, side thrusters and nose beacon."""

import math

from catalog import colors
from catalog.descent_module import layout
from catalog.paints import machined
from catalog.parts import light, place, plumbing
from catalog.parts.deep import GREEN_DARK, GREEN_PALE, STEEL_DEEP, around, beam, hatch, lamp
from workshop import shapes, sweep

LOW, HIGH, RADIUS = layout.POD
PROFILE = [(0.0, LOW), (0.19, LOW), (0.3, LOW + 0.07), (RADIUS, LOW + 0.22), (RADIUS, HIGH - 0.2),
           (0.29, HIGH - 0.1), (0.16, HIGH - 0.03), (0.0, HIGH)]
MID = (LOW + HIGH) / 2


def hull(into, atlas):
    """Tier 1: the capsule, two bolted bands, three blue ports, a hatch on top,
    the lugs its four cables hang from and a ring of lamps round its foot."""
    body = sweep.lathe(PROFILE, sides=16, smooth=True)
    body.sharp_angle = math.radians(60)
    into.add(body, "hull", machined(GREEN_PALE, 3, soot=0.0), atlas.tiled("plates", 0.7)(body))
    for z in (LOW + 0.2, HIGH - 0.22):
        band = shapes.cylinder(RADIUS + 0.012, 0.05, sides=16, smooth=False).transform((0, 0, z))
        into.add(band, "hull", machined(GREEN_DARK, 4, soot=0.0), atlas.fit("strap")(band))
    window = shapes.cylinder(RADIUS + 0.008, 0.14, sides=16, smooth=False).transform((0, 0, MID - 0.07))
    into.add(window, "lamp", colors.LAMP, atlas.fit("ribbon_blue")(window))
    place(into, hatch(atlas, 0.11), (0, 0, HIGH - 0.04))
    for k in range(4):
        a = math.pi / 4 + k * math.pi / 2
        lug = shapes.box((0.05, 0.05, 0.07), bevel=0.008)
        place(into, [(lug, "hull", machined(GREEN_DARK, 5, soot=0.0), atlas.solid("plain")(lug))],
              (0.16 * math.cos(a), 0.16 * math.sin(a), HIGH - 0.1))
    for x, y, _ in around(8, 0.3, phase=math.pi / 8):
        place(into, lamp(atlas, "blue", 0.032), (x, y, LOW + 0.05))


def cables(into, atlas):
    """Tier 1: four cables from the pod's lugs to the winch housing."""
    top = layout.TOP
    for k in range(4):
        a = math.pi / 4 + k * math.pi / 2
        place(into, plumbing.cable([(0.16 * math.cos(a), 0.16 * math.sin(a), HIGH - 0.04),
                                    (0.19 * math.cos(a), 0.19 * math.sin(a), 1.45),
                                    (0.2 * math.cos(a), 0.2 * math.sin(a), top)], 0.012, colors.GROOVE))


def clamps(into, atlas):
    """Tier 2: three fins at the pod's foot and four arms from the legs that
    grip it, each ending in a padded jaw."""
    for k in range(3):
        a = 2 * math.pi * k / 3 + math.pi / 2
        fin = shapes.prism([(0.3, LOW + 0.34), (0.3, LOW + 0.08), (0.48, LOW), (0.48, LOW + 0.1)], 0.03)
        place(into, [(fin, "hull", machined(STEEL_DEEP, 6, soot=0.0), atlas.fit("plate")(fin))],
              (0, 0, 0), (math.pi / 2, 0, a))
    for k in range(4):
        foot = layout.leg(k, MID)
        a = math.atan2(foot[1], foot[0])
        jaw = (0.33 * math.cos(a), 0.33 * math.sin(a), MID)
        place(into, beam(atlas, foot, jaw, 0.06, GREEN_PALE, 7 + k, depth=0.05))
        pad = shapes.box((0.06, 0.12, 0.14), bevel=0.01)
        place(into, [(pad, "hull", machined(STEEL_DEEP, 8, soot=0.0), atlas.fit("plate")(pad))],
              (0.355 * math.cos(a), 0.355 * math.sin(a), MID - 0.07), (0, 0, a))


def armour(into, atlas):
    """Tier 3: two heavy bands round the hull in pale steel, a nose beacon of
    blue light and two side thrusters with a lit nozzle."""
    for z, h in ((LOW + 0.1, 0.07), (HIGH - 0.18, 0.07)):
        band = shapes.cylinder(RADIUS + 0.025, h, sides=16, smooth=False,
                               top_radius=RADIUS + 0.018).transform((0, 0, z))
        into.add(band, "hull", machined(GREEN_PALE, 9, soot=0.0), atlas.fit("plate_wide")(band))
    nose = shapes.octahedron(0.06).transform((0, 0, HIGH + 0.05), scale=(1, 1, 1.5))
    into.add(nose, *light(atlas, "blue"))
    for sign in (1, -1):
        pod = shapes.cylinder(0.065, 0.3, sides=10, bevel=0.01, smooth=False)
        nozzle = shapes.cylinder(0.05, 0.02, sides=10, smooth=False).transform((0, 0, 0.3))
        place(into, [(pod, "hull", machined(GREEN_DARK, 10, soot=0.0), atlas.fit("bolt")(pod)),
                     (nozzle, *light(atlas, "blue"))],
              (-0.05, sign * 0.3, MID - 0.18), (math.pi / 2 * sign * -1, 0, 0))
