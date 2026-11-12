"""The jelly's parts: a translucent bell with glowing lobes inside it, thin
trailing strands with a lit tip, and a frill of oral arms."""

import math

from catalog import colors
from workshop import shapes, sweep
from workshop.colors import linear, mix

CROWN, RIM = linear("#b9a2f4"), linear("#f0a6e4")
STRAND, FRILL = linear("#d9b8f4"), linear("#f5c2ea")
PROFILE = [(0.0, 0.135), (0.05, 0.13), (0.1, 0.108), (0.15, 0.058), (0.175, 0.005), (0.168, -0.022),
           (0.15, -0.03)]


def dome(model, group):
    """The bell, paler and clearer on its crown, pinker and thicker at its rim,
    and four lobes glowing inside it."""
    shape = sweep.lathe(PROFILE, sides=14)

    def paint(p, normal):
        rim = min(1.0, max(0.0, (0.06 - p.z) / 0.06))
        return (*mix(CROWN, RIM, rim), 0.5 + 0.32 * rim)
    model.add(group, shape, "jelly", paint, bone="Bell")
    for k in range(4):
        a = math.pi / 2 * k
        lobe = shapes.sphere(0.03, subdivisions=1)
        lobe.transform((0.065 * math.cos(a), 0.065 * math.sin(a), 0.05), scale=(1, 1, 0.5))
        model.add(group, lobe, "glow_pink", colors.GLOW_PINK, bone="Bell")


def strands(model, group, angle, weights):
    """Two thin strands trailing from the rim at [angle], blended along their
    bones by [weights], each ending in a lit bead."""
    for side in (-1, 1):
        x, y = 0.075 * math.cos(angle) - side * 0.02 * math.sin(angle), \
            0.075 * math.sin(angle) + side * 0.02 * math.cos(angle)
        path = [(x, y, z) for z in (0.0, -0.1, -0.22, -0.36)]
        path = [(px + 0.012 * side * math.sin(z * 14), py, z) for (px, py, z) in path]
        strand = sweep.tube(path, [0.008, 0.007, 0.006, 0.004], sides=3)
        model.add(group, strand, "jelly", lambda p, n: (*STRAND, 0.85), bone=weights)
        bead = shapes.octahedron(0.011).transform(path[-1])
        model.add(group, bead, "glow_pink", colors.GLOW_PINK, bone=weights)


def arms(model, group, angle, weights):
    """The oral arms: three ribbons of frill hanging from the bell's centre."""
    for k in range(3):
        a = 2 * math.pi * k / 3 + angle
        path = [(0.02 * math.cos(a) * t, 0.02 * math.sin(a) * t, z)
                for t, z in zip((1.0, 1.4, 1.7, 1.0), (-0.01, -0.1, -0.22, -0.34))]
        side = [(-math.sin(a), math.cos(a), 0)] * 4
        frill = sweep.ribbon(path, [0.03, 0.045, 0.035, 0.01], side)
        model.add(group, frill, "jelly", lambda p, n: (*FRILL, 0.8), bone=weights)
