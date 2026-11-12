"""Tier 2 of the descent module, what rising adds: cross-bracing and a ring
beam on the gantry, a railed catwalk round it with its ladder, ballast tanks
piped to the well, counterweights, winch drums, floodlights, the clamp arms
and fins of the pod, and the reef taking hold of the foot."""

from catalog import colors
from catalog.descent_module import layout, pod
from catalog.descent_module.layout import DECK, TOP
from catalog.paints import machined
from catalog.parts import Into, place, plumbing, rails, reef, sides_and_top
from catalog.parts.deep import GREEN, GREEN_DARK, GREEN_PALE, beam, frame_of, lamp, lying, rail
from workshop import shapes

CATWALK = 0.95  # its height
REEF = ((1.02, -0.92, 1.0), (-0.96, -0.98, 0.8), (1.0, 0.95, 0.7), (-1.0, 0.7, 0.6))


def tier2(model, group):
    atlas, into = model.atlas, Into(model, group)
    _bracing(into, atlas)
    _catwalk(into, atlas)
    _tanks(into, atlas)
    _counterweights(into, atlas)
    _top_works(into, atlas)
    pod.clamps(into, atlas)
    for x, y, size in REEF:
        reef.cluster(into, model.rng, atlas, (x, y, 0.0), size * 0.8, 2)


def _bracing(into, atlas):
    """X braces on the two back faces; the front ones stay open on the pod."""
    low, high = 0.3, 1.5
    for k in (0, 1):
        a, b = layout.leg(k, low), layout.leg(k, high)
        c, d = layout.leg((k + 1) % 4, low), layout.leg((k + 1) % 4, high)
        place(into, beam(atlas, a, d, 0.04, GREEN_DARK, 60 + k) + beam(atlas, c, b, 0.04, GREEN_DARK, 64 + k))
    place(into, frame_of(atlas, layout.corners(1.3), GREEN_PALE, 70, 0.06))


def _catwalk(into, atlas):
    """An L of grating on the two back faces, railed, its ladder at the end."""
    w = layout.half_width(CATWALK) + 0.12
    walks = (shapes.box((2 * w, 0.2, 0.035), bevel=0.006).transform((0, w, CATWALK)),
             shapes.box((0.2, 2 * w - 0.1, 0.035), bevel=0.006).transform((-w, -0.05, CATWALK)))
    for plank, seed in zip(walks, (71, 72)):
        into.add(plank, "hull", machined(GREEN_PALE, seed, soot=0.0),
                 sides_and_top(atlas, plank, "strap", "tread"))
    e, z = w + 0.1, CATWALK + 0.035
    place(into, rail(atlas, [(-e, -w, z), (-e, e, z), (e - 0.1, e, z), (e - 0.1, w - 0.1, z)]))
    place(into, rails.ladder(atlas, CATWALK - DECK, 0.12), (-w, -w - 0.02, DECK))
    for x, y in ((-e, e), (-e, -w)):
        place(into, lamp(atlas, "blue", 0.035), (x, y, CATWALK + 0.2))


def _tanks(into, atlas):
    for k, x in enumerate((-0.38, 0.02)):
        tank = lying(shapes.cylinder(0.1, 0.4, sides=12, bevel=0.012, smooth=True))
        parts = [(tank, "hull", machined(GREEN_PALE, 80 + k, soot=0.3, height=0.2),
                  atlas.tiled("weathered", 0.5)(tank))]
        for dx in (-0.12, 0.12):
            band = lying(shapes.cylinder(0.106, 0.04, sides=12, smooth=False)).transform((dx, 0, 0))
            parts.append((band, "hull", colors.WHITE, atlas.fit("hazard")(band)))
        place(into, parts, (x, -0.86, DECK + 0.11))
    place(into, plumbing.pipe(atlas, [(0.22, -0.86, DECK + 0.13), (0.34, -0.76, DECK + 0.3),
                                      (0.3, -0.58, DECK + 0.24)], 0.03, colors.PIPE, flanges=1, seed=2))


def _counterweights(into, atlas):
    for sign in (1, -1):
        weight = shapes.box((0.15, 0.15, 0.32), bevel=0.012)
        stripes = shapes.box((0.156, 0.156, 0.07), bevel=0.0)
        place(into, [(weight, "hull", machined(GREEN_DARK, 90, soot=0.0), atlas.fit("plate")(weight)),
                     (stripes.transform((0, 0, 0.04)), "hull", colors.WHITE, atlas.fit("hazard")(stripes))],
              (sign * 0.44, 0, 0.72))
        place(into, plumbing.cable([(sign * 0.44, 0, 1.04), (sign * 0.4, 0, TOP - 0.02)], 0.012, colors.GROOVE))


def _top_works(into, atlas):
    top = TOP + layout.HOUSING[1] - 0.03
    for sign in (-1, 1):
        drum = lying(shapes.cylinder(0.085, 0.36, sides=12, bevel=0.01, smooth=False), "y")
        place(into, [(drum, "hull", machined(GREEN_DARK, 91, soot=0.0), atlas.fit("strap")(drum))],
              (sign * 0.15, 0, top + 0.09))
    motor = shapes.box((0.2, 0.2, 0.16), bevel=0.015, bottom=False)
    place(into, [(motor, "hull", machined(GREEN, 92, soot=0.0), atlas.fit("vent")(motor))],
          (-0.18, 0.2, top))
    for k in range(4):
        x, y, _ = layout.leg(k, TOP)
        head = shapes.box((0.09, 0.09, 0.06), bevel=0.01, bottom=False)
        place(into, [(head, "hull", machined(GREEN_DARK, 93 + k, soot=0.0), atlas.fit("bolt")(head))]
              + [(g.transform((0, 0, 0.1)), m, p, u) for g, m, p, u in lamp(atlas, "white", 0.045)],
              (x, y, TOP + 0.04))
