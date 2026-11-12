"""The citadel's curtain: four walls of grown stone between the round towers,
low at the first tier and, at the second, crowned with merlons and thorns."""

import math

from catalog import colors
from catalog.coral_citadel.stone import grown, out_of, stone
from catalog.parts import Into, place, reef
from workshop import shapes

HALF = 0.66  # the towers' centres, at (+-HALF, +-HALF)
WALL = (0.17, 0.42)  # thickness, height
GATE = 0.5  # the gatehouse's width
GATE_SIDE = 1  # the wall (angle k * 90 degrees) that holds the gate: the north one


def pieces(angle, gate):
    """The runs of the wall facing [angle]: (offset along it, size)."""
    length = 2 * HALF - 0.36
    side = length / 2 - GATE / 2
    if gate:
        return [(-length / 4 - GATE / 4, side), (length / 4 + GATE / 4, side)]
    return [(0.0, length)]


def _along(angle, offset):
    x, y = HALF * math.cos(angle), HALF * math.sin(angle)
    return x - math.sin(angle) * offset, y + math.cos(angle) * offset


def curtain(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    thick, height = WALL
    for k in range(4):
        angle = k * math.pi / 2
        for offset, size in pieces(angle, k == GATE_SIDE):
            seed = rng.randrange(1000)
            body = shapes.box((size + 0.04, thick, height), bevel=0.02, bottom=False)
            body.displace(lambda p: (0, -p.y * 0.25 * max(p.z, 0) / height, 0))
            grown(body, seed, 0.025)
            x, y = _along(angle, offset)
            body.transform((x, y, -0.02), (0, 0, angle + math.pi / 2))
            into.add(body, "reef", stone(rng, seed), atlas.tiled("coral", 1.0))


def battlements(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    thick, height = WALL
    for k in range(4):
        angle = k * math.pi / 2
        for offset, size in pieces(angle, k == GATE_SIDE):
            x, y = _along(angle, offset)
            count = max(1, round(size / 0.2))
            for m in range(count):
                t = (m + 0.5) / count - 0.5
                merlon = grown(shapes.box((0.09, thick * 0.8, 0.09), bevel=0.015, bottom=False),
                               rng.randrange(1000), 0.012, 0.2)
                mx, my = x - math.sin(angle) * t * size, y + math.cos(angle) * t * size
                place(into, [(merlon, "reef", stone(rng, m), atlas.tiled("coral", 1.0)(merlon))],
                      (mx, my, height - 0.025), (0, 0, angle + math.pi / 2))
            for t in (-0.25, 0.25):
                px = x - math.sin(angle) * t * size + math.cos(angle) * thick * 0.4
                py = y + math.cos(angle) * t * size + math.sin(angle) * thick * 0.4
                out = out_of(math.cos(angle), math.sin(angle))
                out.z = 0.35
                place(into, reef.thorn(atlas, rng, rng.uniform(0.22, 0.3), 0.035, out,
                                       colors.CORAL_STONE, colors.CORAL_PINK), (px, py, height * 0.55))
