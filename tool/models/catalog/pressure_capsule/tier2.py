"""Tier 2 of the pressure capsule, what rising adds: five armoured ribs over
the hull, a belly of plates, a ring of portholes, two more gas bottles, flood-
lights on posts, and the two hydrothermal chimneys of black rock the capsule
is built to assault, their vents glowing, with the reef at their foot."""

import math

from catalog import colors
from catalog.paints import machined
from catalog.parts import Into, hatches, place, plumbing, reef
from catalog.parts.deep import (BASALT, STEEL, STEEL_DEEP, WHITE, YELLOW, around, lamp, paint_basalt,
                                swell)
from catalog.pressure_capsule import layout
from catalog.pressure_capsule.layout import FRONT, RADIUS, on_sphere
from workshop import shapes, sweep

TURN = math.radians(72)
CHIMNEYS = ((-0.78, -0.4, 0.24, 1.2), (0.3, 0.82, 0.18, 0.85))  # x, y, radius at the foot, height
REEF = ((0.95, -0.55, 0.9), (0.5, -0.98, 0.8), (-0.95, -0.4, 0.8), (-0.4, -0.95, 0.7))


def tier2(model, group):
    atlas, into = model.atlas, Into(model, group)
    _ribs(into, atlas)
    _belly(into, atlas)
    _portholes(into, atlas)
    _bottles(into, atlas)
    _chimneys(model, into, atlas)
    for x, y, size in REEF:
        reef.cluster(into, model.rng, atlas, (x, y, 0.0), size * 0.8, 2)


def _ribs(into, atlas):
    for k in range(5):
        a = FRONT + math.radians(36) + k * TURN
        path = [on_sphere(a, math.radians(d), RADIUS + 0.03) for d in range(-70, 71, 14)]
        rib = sweep.tube(path, [0.03] * len(path), sides=5, cap=False)
        into.add(rib, "hull", machined(STEEL_DEEP, 30 + k, soot=0.0), atlas.tiled("plates", 0.5)(rib))


def _belly(into, atlas):
    steps = [math.radians(d) for d in (-76, -60, -44, -28)]
    profile = [(on_sphere(0, a, RADIUS + 0.025)[0], on_sphere(0, a, RADIUS + 0.025)[2]) for a in steps]
    armour = sweep.lathe(profile, sides=12, phase=math.pi / 12, smooth=False)
    into.add(armour, "hull", machined(STEEL, 36, soot=0.0), atlas.fit("plate")(armour))


def _portholes(into, atlas):
    for k in range(1, 5):
        a = FRONT + k * TURN
        place(into, hatches.porthole(atlas, 0.05, "porthole_cyan", seed=k),
              on_sphere(a, 0.0, RADIUS - 0.008), (0, 0, a + math.pi / 2))


def _bottles(into, atlas):
    for k, a in enumerate((math.radians(25), math.radians(-110))):
        x, y = 0.85 * math.cos(a), 0.85 * math.sin(a)
        body = shapes.cylinder(0.08, 0.42, sides=12, bevel=0.01, smooth=True)
        band = shapes.cylinder(0.084, 0.05, sides=12, smooth=False).transform((0, 0, 0.25))
        place(into, [(body, "hull", machined(YELLOW, 40 + k, soot=0.3, height=0.2),
                      atlas.tiled("plates", 0.5)(body)),
                     (band, "hull", WHITE, atlas.fit("hazard")(band))], (x, y, layout.PLINTH[1]))
        place(into, plumbing.pipe(atlas, [(x, y, 0.6), (x * 0.78, y * 0.78, 0.74),
                                          on_sphere(a, -0.3, RADIUS - 0.02)],
                                  0.022, colors.PIPE, flanges=1, seed=k))
    for x, y, a in around(4, 0.9, phase=math.pi / 4)[1:3]:
        post = shapes.cylinder(0.025, 0.42, sides=6, bottom=False)
        place(into, [(post, "hull", colors.METAL_DARK, None)] + [
            (g.transform((0, 0, 0.45)), m, p, u) for g, m, p, u in lamp(atlas, "white", 0.05)],
              (x * 0.95, y * 0.95, layout.PLINTH[1]))


def _chimneys(model, into, atlas):
    base = layout.PLINTH[1]
    for k, (x, y, radius, height) in enumerate(CHIMNEYS):
        profile = [(radius * 1.5, -0.02), (radius * 1.1, height * 0.12), (radius * 0.8, height * 0.35),
                   (radius * 0.9, height * 0.55), (radius * 0.6, height * 0.8),
                   (radius * 0.72, height), (radius * 0.42, height - 0.05)]
        spire = swell(sweep.lathe(profile, sides=9), 50 + k, 0.07, 0.1).transform((x, y, base))
        into.add(spire, "reef", paint_basalt(50 + k, BASALT, warm=0.9), atlas.tiled("basalt", 0.7)(spire))
        vent = shapes.cylinder(radius * 0.42, 0.02, sides=10, smooth=False)
        place(into, [(vent, "lamp", colors.LAMP, atlas.solid("lava")(vent))], (x, y, base + height - 0.04))
        place(into, lamp(atlas, "molten", 0.03), (x, y, base + height + 0.03))
