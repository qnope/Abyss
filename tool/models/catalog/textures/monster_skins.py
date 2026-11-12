"""The skins of the monsters' atlas, painted with numpy on a workshop Canvas:
near-white greys that the vertex colours tint (a slimy hide, glassy scales,
chitin plates, a scarred leathery hide), and the eyes, which are lit.
Seamless tiles repeat on a body without a seam (Atlas.tiled)."""

import numpy

from catalog.textures.marks import blend

DARK = numpy.array((0.015, 0.012, 0.02))


def skin(canvas):
    """A slimy hide: soft blotches, fine pores, a few pale warts."""
    shade = 0.8 + 0.14 * canvas.fbm(3, octaves=3, seed=21) + 0.08 * canvas.fbm(9, octaves=2, seed=22)
    pores = canvas.pits(20, radius=0.3, seed=23) ** 0.8
    warts = canvas.pits(6, radius=0.18, seed=24) ** 1.2
    return numpy.clip(shade * (1 - 0.3 * pores) + 0.25 * warts, 0, 1)


def scales(canvas):
    """Overlapping scales: each a little lighter at its crown, a dark joint
    between them."""
    first, second, value = canvas._voronoi(7, 31)
    joint = numpy.clip((second - first) / 0.12, 0, 1)
    crown = numpy.clip(1 - first / 0.7, 0, 1)
    shade = (0.7 + 0.25 * crown + 0.05 * value) * (0.6 + 0.4 * joint)
    return numpy.clip(shade + 0.1 * canvas.fbm(10, octaves=2, seed=32), 0, 1)


def plates(canvas):
    """Chitin: bands across, each domed, grooves between, pitted and scuffed."""
    band = (canvas.t * 3) % 1.0
    dome = numpy.sin(numpy.pi * band) ** 0.6
    groove = numpy.clip(numpy.minimum(band, 1 - band) / 0.07, 0, 1)
    ribs = 0.5 + 0.5 * numpy.sin(canvas.s * 2 * numpy.pi * 6 + 4 * canvas.fbm(2, seed=41))
    shade = (0.78 + 0.22 * dome) * (0.55 + 0.45 * groove) * (0.9 + 0.1 * ribs)
    pits = canvas.pits(16, radius=0.25, seed=42)
    scuffs = numpy.clip(canvas.fbm(5, octaves=3, seed=43) * 1.6 - 0.5, 0, 1)
    return numpy.clip(shade * (1 - 0.3 * pits) * (1 - 0.25 * scuffs), 0, 1)


def hide(canvas):
    """A leathery, scarred hide: big wrinkles, pale healed scars, pits."""
    wrinkles = canvas.cracks(5, width=0.22, seed=51) ** 1.5
    shade = 0.84 + 0.12 * canvas.fbm(3, octaves=4, seed=52) - 0.2 * wrinkles
    scars = numpy.clip(1 - numpy.abs(canvas.fbm(2, octaves=2, seed=53) - 0.2) / 0.04, 0, 1)
    pits = canvas.pits(14, radius=0.22, seed=54)
    return numpy.clip((shade + 0.3 * scars) * (1 - 0.3 * pits), 0, 1)


def eye(colour):
    """A glowing eye seen head on: a bright iris that fades toward its edge, a
    black slit for a pupil, a dark rim; lit by itself (the lamp material)."""
    def paint(canvas):
        d = numpy.hypot(canvas.x - canvas.width / 2, canvas.y - canvas.height / 2) / (canvas.width / 2)
        iris = numpy.clip(1.15 - 0.55 * d ** 2, 0, 1.1)
        slit = numpy.clip(numpy.abs(canvas.x - canvas.width / 2) / (canvas.width * 0.07) - 0.7, 0, 1)
        lit = blend(numpy.broadcast_to(DARK, canvas.x.shape + (3,)), colour * iris[..., None], slit)
        return blend(lit, DARK, numpy.clip((d - 0.82) / 0.08, 0, 1))
    return paint
