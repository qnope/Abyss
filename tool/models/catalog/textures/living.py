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

