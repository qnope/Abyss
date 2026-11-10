"""Photovoltaic cells: deep blue wafers with clipped corners, silver
fingers and busbars, each wafer its own shade, in an aluminium frame."""

import numpy

from catalog.textures.marks import blend, edge_distance, seam
from workshop.colors import linear

WAFER = numpy.array(linear("#1d3b8a"))
WAFER_DEEP = numpy.array(linear("#10235a"))
SILVER = numpy.array(linear("#c9d4e6"))
FRAME = numpy.array(linear("#aab4c4"))


def cells(across=4, up=6, frame=6.0):
    def paint(canvas):
        inner_w, inner_h = canvas.width - 2 * frame, canvas.height - 2 * frame
        w, h = inner_w / across, inner_h / up
        lx, ly = (canvas.x - frame) % w, (canvas.y - frame) % h
        gap = numpy.minimum(numpy.minimum(lx, w - lx), numpy.minimum(ly, h - ly))
        corner = numpy.minimum(numpy.abs(lx - w / 2) + numpy.abs(ly - h / 2) - (w + h) * 0.42, 0)
        wafer = numpy.clip(gap - 1.0, 0, 1) * numpy.clip(-corner, 0, 1)
        index = (numpy.floor((canvas.x - frame) / w) + across * numpy.floor((canvas.y - frame) / h))
        shade = canvas.rng.uniform(0.0, 1.0, across * up + across + up + 2)[
            numpy.clip(index.astype(int), 0, across * up + across + up + 1)]
        blue = WAFER * (1 - shade[..., None]) + WAFER_DEEP * shade[..., None]
        blue = blue * (0.85 + 0.3 * canvas.t)[..., None]
        fingers = (numpy.abs((lx / w * 14) % 1 - 0.5) > 0.44).astype(float) * 0.5
        busbars = numpy.minimum(numpy.abs(lx - w / 3), numpy.abs(lx - 2 * w / 3)) < 0.9
        lines = numpy.maximum(fingers * 0.5, busbars.astype(float))
        colour = blend(numpy.broadcast_to(SILVER * 0.55, blue.shape).copy(), blue, wafer)
        colour = blend(colour, SILVER, lines * wafer * 0.6)
        border = numpy.clip(frame - edge_distance(canvas), 0, 1)
        framed = FRAME * seam(edge_distance(canvas), 1.5, 2.5)[..., None]
        return blend(colour, framed, border)
    return paint
