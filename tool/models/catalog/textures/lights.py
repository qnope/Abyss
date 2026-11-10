"""The lamps' tiles, which the lamp material both reflects and emits: lit
panes behind their mullions, portholes, plain light colours, and the glass
that only reflects (painted streaks of the light above)."""

import numpy

from catalog.textures.marks import blend, edge_distance, seam
from workshop.colors import linear

# Saturated and below 1: the lamp's strength (palette) lifts them past the
# bloom's threshold without bleaching them white.
AMBER = numpy.array(linear("#ff7f2a")) * 0.85
CYAN = numpy.array(linear("#30e0ff")) * 0.85
PINK = numpy.array(linear("#ff4aa5")) * 0.85
GOLD = numpy.array(linear("#ffa915")) * 0.85
WHITE = numpy.array(linear("#eaf6ff"))
DARK = numpy.array((0.02, 0.025, 0.03))


def solid(colour):
    return lambda canvas: numpy.broadcast_to(colour, (canvas.height, canvas.width, 3))


def panes(colour, across=2, up=3, frame=5.0, mullion=3.0):
    """A window of [across] x [up] panes of light, brighter low down, a few
    dimmer, some crossed by the shadow of someone inside."""
    def paint(canvas):
        w, h = canvas.width / across, canvas.height / up
        lx, ly = canvas.x % w, canvas.y % h
        inner = numpy.minimum(numpy.minimum(lx, w - lx), numpy.minimum(ly, h - ly))
        glass = numpy.clip((inner - mullion / 2) / 1.5, 0, 1)
        glass *= numpy.clip((edge_distance(canvas) - frame) / 1.5, 0, 1)
        pane = (numpy.floor(canvas.x / w) + across * numpy.floor(canvas.y / h)).astype(int)
        level = canvas.rng.uniform(0.55, 1.0, across * up)[pane]
        glow = level * (1.05 - 0.35 * canvas.t) * (0.92 + 0.08 * canvas.noise(4))
        figure = canvas.disc(canvas.width * 0.62, canvas.height * 0.18, w * 0.16, 3)
        figure = numpy.maximum(figure, canvas.box(canvas.width * 0.56, 0, canvas.width * 0.68,
                                                  canvas.height * 0.16, 3))
        glow = glow * (1 - 0.55 * figure)
        return blend(numpy.broadcast_to(DARK, glow.shape + (3,)), colour * glow[..., None], glass)
    return paint


def ribbon(colour, mullions=6):
    """A long band of light cut by thin mullions: a bridge's windows."""
    def paint(canvas):
        phase = (canvas.s * mullions) % 1.0
        glass = numpy.clip(numpy.minimum(phase, 1 - phase) * canvas.width / mullions / 1.5 - 1, 0, 1)
        glass *= numpy.clip((edge_distance(canvas) - 4) / 1.5, 0, 1)
        glow = (1.0 - 0.3 * canvas.t) * (0.85 + 0.15 * canvas.noise(3))
        return blend(numpy.broadcast_to(DARK, glow.shape + (3,)), colour * glow[..., None], glass)
    return paint


def porthole(colour):
    """A round pane, bright at its heart, a reflection across its top."""
    def paint(canvas):
        cx, cy, r = canvas.width / 2, canvas.height / 2, canvas.width / 2
        d = numpy.hypot(canvas.x - cx, canvas.y - cy) / r
        glow = numpy.clip(0.8 - 0.4 * d * d, 0, 1)
        arc = numpy.clip(1 - numpy.abs(d - 0.7) / 0.08, 0, 1) * (canvas.y > cy + r * 0.2)
        colour_ = colour * glow[..., None]
        colour_ = blend(colour_, numpy.ones(3), arc * 0.6)
        return blend(colour_, DARK, numpy.clip((d - 0.92) / 0.05, 0, 1))
    return paint


def glass(canvas):
    """Glass reflecting the light above: brighter toward the top, one soft
    slanted gleam and a thin one, silt settled along the bottom edge."""
    sky = 0.62 + 0.38 * canvas.t ** 1.5
    slant = canvas.s * 0.8 + canvas.t
    gleam = numpy.clip(1 - numpy.abs(slant - 1.05) / 0.16, 0, 1) ** 2 * 0.35
    gleam += numpy.clip(1 - numpy.abs(slant - 1.32) / 0.025, 0, 1) * 0.3
    shade = (sky + gleam) * (0.95 + 0.05 * canvas.noise(4))
    silt = numpy.clip(1 - canvas.y / (canvas.height * 0.14), 0, 1) ** 2 * 0.45
    return (shade * (1 - silt))[..., None]
