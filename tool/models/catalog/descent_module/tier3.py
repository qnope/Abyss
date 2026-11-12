"""Tier 3 of the descent module, its crown: a halo of blue light round the
well, a mast with a beacon (the node Beacon) and a dish over the winch
housing, a crane boom with a crate on its hook, a railed roof, posts of
light on the legs, the pod's armour and thrusters, and more reef."""

import math

from catalog import colors
from catalog.descent_module import layout, pod
from catalog.descent_module.layout import DECK, TOP
from catalog.paints import machined
from catalog.parts import Into, fittings, place, plumbing, props, rails, reef
from catalog.parts.deep import GREEN_DARK, GREEN_PALE, around, beam, lamp, ring_tube
from workshop import shapes

ROOF = TOP + layout.HOUSING[1] - 0.03  # the winch housing's top
REEF = ((1.05, -0.4, 0.7), (-0.5, -1.04, 0.7), (-1.04, -0.3, 0.6), (0.3, 1.04, 0.6))


def tier3(model, group):
    atlas, into = model.atlas, Into(model, group)
    _halo(into, atlas)
    _crown(model, group, into, atlas)
    _boom(into, atlas)
    _strips(into, atlas)
    pod.armour(into, atlas)
    for x, y, size in REEF:
        reef.cluster(into, model.rng, atlas, (x, y, 0.0), size * 0.8, 2)


def _halo(into, atlas):
    ring = ring_tube(0.57, 0.03, sides=6, points=40)
    place(into, [(ring, "lamp", colors.LAMP, atlas.solid("blue")(ring))], (0, 0, DECK + 0.17))
    for x, y, _ in around(12, 0.56):
        post = shapes.cylinder(0.02, 0.1, sides=6, bottom=False)
        place(into, [(post, "hull", colors.METAL_DARK, None)] + lamp(atlas, "blue", 0.03),
              (x, y, DECK + 0.1))
        place(into, lamp(atlas, "blue", 0.03), (x, y, DECK + 0.22))


def _strips(into, atlas):
    """A line of blue light up the inside face of each leg."""
    for k in range(4):
        low, high = layout.leg(k, 0.35), layout.leg(k, TOP - 0.1)
        inward = (-low[0] / abs(low[0]), -low[1] / abs(low[1]))
        lift = [(c + 0.05 * s) for c, s in zip(low[:2], inward)]
        top = [(c + 0.05 * s) for c, s in zip(high[:2], inward)]
        place(into, beam(atlas, (*lift, low[2]), (*top, high[2]), 0.034, GREEN_PALE, 120 + k,
                         tile="blue", material="lamp"))


def _crown(model, group, into, atlas):
    place(into, fittings.mast(atlas, 0.4, 0.035, GREEN_DARK, 100), (0, 0, ROOF))
    beacon = model.piece(f"{group}/Beacon", (0, 0, ROOF + 0.4))
    place(beacon, fittings.beacon(atlas, 0.07, "blue", GREEN_DARK, 101))
    pole = shapes.cylinder(0.02, 0.22, sides=6, bottom=False)
    place(into, [(pole, "hull", colors.METAL_DARK, None)], (0.21, 0.2, ROOF))
    place(into, fittings.dish(atlas, 0.14, 0.08, GREEN_PALE, 102), (0.21, 0.2, ROOF + 0.22),
          (math.radians(-35), 0, math.radians(-135)))
    edge = [(0.27, 0.27, ROOF), (-0.27, 0.27, ROOF), (-0.27, -0.27, ROOF), (0.27, -0.27, ROOF)]
    place(into, rails.railing(atlas, edge, 0.1))
    for k in range(4):
        x, y, _ = layout.leg(k, TOP)
        post = shapes.box((0.04, 0.04, 0.2), bevel=0.008, bottom=False)
        place(into, [(post, "hull", machined(GREEN_PALE, 103 + k, soot=0.0), atlas.fit("plate_tall")(post))]
              + [(g.transform((0, 0, 0.23)), m, p, u) for g, m, p, u in lamp(atlas, "blue", 0.04)],
              (x * 1.02, y * 1.02, TOP + 0.1))


def _boom(into, atlas):
    """A jib over the hut, a crate on its hook just above the hut's roof."""
    root, mid, tip = (0.1, 0.0, ROOF + 0.06), (0.3, 0.0, ROOF + 0.45), (0.8, 0.0, ROOF + 0.04)
    place(into, beam(atlas, root, mid, 0.05, GREEN_PALE, 110, depth=0.06)
          + beam(atlas, mid, tip, 0.05, GREEN_PALE, 111, depth=0.06)
          + beam(atlas, root, tip, 0.04, GREEN_DARK, 112))
    top = DECK + 0.4 + 0.04 + 0.16
    place(into, plumbing.cable([(0.8, 0, ROOF), (0.8, 0, 1.2), (0.8, 0, top + 0.08)], 0.01, colors.GROOVE))
    block = shapes.box((0.07, 0.07, 0.08), bevel=0.01)
    place(into, [(block, "hull", machined(GREEN_DARK, 113, soot=0.0), atlas.fit("bolt")(block))],
          (0.8, 0, top))
    place(into, props.crate(atlas, (0.2, 0.2, 0.16), colors.CORAL_ORANGE, 114), (0.8, 0, DECK + 0.44))
