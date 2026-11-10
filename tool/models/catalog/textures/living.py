"""The tiles of living stuff: the pores and speckle of coral stone, seamless
so that a reef wall tiles it without a seam."""

import numpy

from catalog.textures.marks import blend
from workshop.colors import linear

ROSE = numpy.array(linear("#e7a3b4"))
PALE = numpy.array(linear("#f4ece0"))


def coral(canvas):
    """Reef rock: a mottled crust, round pores, meandering grooves and
    pale and rose specks."""
    shade = 0.82 + 0.12 * canvas.fbm(3, octaves=4, seed=1)
    pores = canvas.pits(22, radius=0.3, seed=2) ** 0.8
    grooves = canvas.cracks(7, width=0.06, seed=3) * numpy.clip(canvas.noise(4, seed=6) + 0.4, 0, 1)
    shade = shade * (1 - 0.45 * pores) * (1 - 0.15 * grooves)
    colour = numpy.broadcast_to(shade[..., None], shade.shape + (3,)).copy()
    specks = (canvas.noise(48, seed=4) > 0.72).astype(float)
    colour = blend(colour, PALE * shade[..., None], specks * 0.7)
    rose = numpy.clip(canvas.fbm(4, octaves=2, seed=5) * 2 - 0.6, 0, 1)
    return blend(colour, ROSE * shade[..., None], rose * 0.35)


def reef_stone(canvas):
    """Blocks cut from the reef, seamless: fine pores, a few deep pits, the
    worn meanders of old brain coral, hairline cracks and pale specks."""
    shade = 0.86 + 0.1 * canvas.fbm(4, octaves=4, seed=11)
    pores = canvas.pits(30, radius=0.25, seed=12) ** 0.8
    pits = canvas.pits(8, radius=0.16, seed=13)

    def wave(axis, seed):
        return numpy.abs(numpy.sin(2 * numpy.pi * (5 * axis + 0.7 * canvas.fbm(2, seed=seed))))
    meander = numpy.clip(1 - wave(canvas.s, 14) * wave(canvas.t, 15) * 4, 0, 1)
    cracks = canvas.cracks(4, width=0.035, seed=16) * numpy.clip(canvas.noise(3, seed=17) + 0.3, 0, 1)
    shade = shade * (1 - 0.3 * pores) * (1 - 0.5 * pits) * (1 - 0.12 * meander) * (1 - 0.35 * cracks)
    colour = numpy.broadcast_to(shade[..., None], shade.shape + (3,)).copy()
    specks = (canvas.noise(40, seed=18) > 0.75).astype(float)
    return blend(colour, PALE * shade[..., None], specks * 0.5)
