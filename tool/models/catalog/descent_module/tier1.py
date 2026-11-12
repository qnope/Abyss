"""Tier 1 of the descent module: its deck with the well the pod is lowered
into (a hazard-striped collar round a pit of blue light), the gantry of four
leaning legs under a winch housing, the pod on its cables and a control hut."""

import math

from catalog import colors
from catalog.descent_module import layout, pod
from catalog.descent_module.layout import DECK, TOP
from catalog.paints import machined
from catalog.parts import Into, hatches, place, sides_and_top
from catalog.parts.deep import GREEN, GREEN_DARK, GREEN_PALE, beam, disc, frame_of
from workshop import shapes, sweep

OUTER, INNER = layout.WELL
HUT = (0.8, 0.0)  # its centre on the deck, between the two right-hand legs


def tier1(model, group):
    atlas, into = model.atlas, Into(model, group)
    _deck(into, atlas)
    _well(into, atlas)
    _gantry(into, atlas)
    _housing(into, atlas)
    _hut(into, atlas)
    pod.hull(into, atlas)
    pod.cables(into, atlas)


def _deck(into, atlas):
    slab = shapes.prism(shapes.chamfered_square(1.92, 0.3), DECK, bevel=0.02, bottom=False)
    slab.subdivide(0.32)
    into.add(slab, "hull", machined(GREEN_DARK, 20, soot=0.5, height=0.2),
             sides_and_top(atlas, slab, "plate_wide", "tread"))
    for k in range(4):
        sx, sy = layout.SIGNS[k]
        shoe = shapes.box((0.2, 0.2, 0.05), bevel=0.01, bottom=False)
        place(into, [(shoe, "hull", machined(GREEN_PALE, 21, soot=0.0), atlas.fit("plate")(shoe))],
              (sx * layout.FOOT, sy * layout.FOOT, DECK))


def _well(into, atlas):
    collar = sweep.lathe([(OUTER + 0.06, DECK - 0.01), (OUTER + 0.06, DECK + 0.07),
                          (OUTER, DECK + 0.11), (INNER + 0.02, DECK + 0.11), (INNER, DECK + 0.07),
                          (INNER, DECK - 0.01)], sides=24, smooth=False)
    into.add(collar, "hull", machined(GREEN_PALE, 22, soot=0.0),
             sides_and_top(atlas, collar, "plate", "hazard"))
    for radius, tile, z in ((INNER - 0.01, "blue", 0.012), (0.33, "dark", 0.03), (0.17, "blue", 0.045)):
        place(into, disc(atlas, radius, tile, sides=24), (0, 0, DECK + z))
    for k in range(8):
        a = 2 * math.pi * k / 8 + math.pi / 8
        stud = shapes.cylinder(0.025, 0.03, sides=6, bottom=False)
        place(into, [(stud, "hull", colors.METAL_DARK, None)],
              ((OUTER + 0.03) * math.cos(a), (OUTER + 0.03) * math.sin(a), DECK + 0.1))


def _gantry(into, atlas):
    for k in range(4):
        place(into, beam(atlas, layout.leg(k, DECK), layout.leg(k, TOP), 0.1, GREEN, 30 + k, period=0.4))
    top = [(x, y, TOP - 0.03) for x, y, _ in layout.corners(TOP)]
    place(into, frame_of(atlas, top, GREEN_PALE, 40, 0.08))


def _housing(into, atlas):
    side, height = layout.HOUSING
    body = shapes.box((side, side, height), bevel=0.02).transform((0, 0, TOP - 0.03))
    body.subdivide(0.2)
    into.add(body, "hull", machined(GREEN, 41, soot=0.0), sides_and_top(atlas, body, "plate_wide", "tread"))
    for sx, sy, turn in ((1, 0, math.pi / 2), (0, -1, 0)):  # the two faces seen from the camera
        strip = shapes.box((0.34, 0.012, 0.07), bevel=0.0, bottom=False)
        place(into, [(strip, "lamp", colors.LAMP, atlas.fit("ribbon_blue")(strip))],
              (sx * (side / 2 + 0.004), sy * (side / 2 + 0.004), TOP + 0.05), (0, 0, turn))


def _hut(into, atlas):
    x, y = HUT
    hut = shapes.box((0.34, 0.5, 0.4), bevel=0.015, bottom=False).transform((x, y, DECK))
    roof = shapes.box((0.4, 0.56, 0.04), bevel=0.01).transform((x, y, DECK + 0.4))
    into.add(hut, "hull", machined(GREEN, 50, soot=0.2, height=0.2), atlas.fit("plate_wide"))
    into.add(roof, "hull", machined(GREEN_DARK, 51, soot=0.0), atlas.fit("tread"))
    pane = shapes.box((0.012, 0.3, 0.17), bevel=0.0, bottom=False)
    pane.faces = [f for i, f in enumerate(pane.faces) if pane.face_normal(i).x > 0.5]
    pane.smooth = [False] * len(pane.faces)
    place(into, [(pane, "lamp", colors.LAMP, atlas.fit("panes_blue")(pane))],
          (x + 0.17, y, DECK + 0.17))
    place(into, hatches.door(atlas, 0.11, 0.26, GREEN_DARK, seed=3), (x, y - 0.25, DECK))
