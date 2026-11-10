"""Paints shared by the models: functions of a corner's position and of its
face's normal giving its colour, before the baked occlusion darkens it."""

from workshop import noise
from workshop.colors import mix, scale


def worked(base, seed, mottle=0.14, frequency=3.0, edge=1.45, side=0.62, grime=None):
    """A worked surface (a slab, a plate): mottled on top, its bevels caught
    by the light as worn edges, its sides darker; [grime] (colour, amount)
    stains it in patches."""
    def paint(p, normal):
        if normal.z > 0.97:
            color = scale(base, 1 + mottle * noise.fbm(p * frequency, seed, octaves=2))
        elif normal.z > 0.25:
            color = scale(base, edge)
        else:
            color = scale(base, side)
        if grime:
            stain, amount = grime
            patch = max(0.0, noise.fbm(p * 2.4, seed + 9, octaves=2))
            color = mix(color, stain, min(1.0, patch * amount * 2))
        return color
    return paint


def organic(base, tip, seed, frequency=4.0, variation=0.18, height=0.6):
    """Living stuff: [base] at its foot to [tip] at [height] above it, mottled."""
    def paint(p, normal):
        t = max(0.0, min(1.0, p.z / height))
        color = mix(base, tip, t)
        return scale(color, 1 + variation * noise.fbm(p * frequency, seed, octaves=2))
    return paint


def flat(color):
    return color


def machined(base, seed, soot=0.4, height=0.5):
    """A machined hull: broad mottled patches, lit on top, shadowed under
    its overhangs, darkened toward its foot (z = 0) by silt within [height]."""
    def paint(p, normal):
        color = scale(base, 1 + 0.12 * noise.fbm(p * 1.4, seed, octaves=2))
        if normal.z > 0.6:
            color = scale(color, 1.12)
        elif normal.z < -0.4:
            color = scale(color, 0.72)
        foot = max(0.0, 1 - max(p.z, 0.0) / height)
        return mix(color, scale(color, 0.45), soot * foot * foot)
    return paint
