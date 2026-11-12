"""How the monsters are coloured: functions of a corner's position and of its
face's normal, giving its colour before the baked occlusion darkens it (as
catalog/paints.py)."""

from workshop import noise
from workshop.colors import mix, scale


def shaded(back, belly, middle, span, seed, variation=0.14, frequency=4.0, scars=None):
    """Counter-shaded as the deep sea's fish: [back] above the height
    [middle], [belly] below it, the two blending over [span] each side;
    mottled by [variation]. [scars], a (colour, frequency), draws pale healed
    scars across it."""
    def paint(p, normal):
        t = (middle + span - p.z) / (2 * span)
        color = mix(back, belly, t)
        if scars:
            line = abs(noise.fbm(p * scars[1], seed + 5, octaves=2))
            color = mix(color, scars[0], 0.8 * max(0.0, 1 - line / 0.05))
        return scale(color, 1 + variation * noise.fbm(p * frequency, seed, octaves=2))
    return paint


def banded(base, ridge, along, period, seed, variation=0.1):
    """[base] with a lighter [ridge] colour in bands every [period] units
    along the axis [along] (0, 1 or 2): the edges of plates and rings."""
    def paint(p, normal):
        phase = (p[along] / period) % 1.0
        color = mix(base, ridge, max(0.0, 1 - min(phase, 1 - phase) * 7))
        return scale(color, 1 + variation * noise.fbm(p * 5, seed, octaves=2))
    return paint


def tipped(base, tip, start, end, along, seed, variation=0.12):
    """[base] fading to [tip] as the coordinate [along] (0, 1 or 2) goes from
    [start] to [end]: an arm paling to its tip, a tail darkening."""
    def paint(p, normal):
        color = mix(base, tip, (p[along] - start) / (end - start))
        return scale(color, 1 + variation * noise.fbm(p * 4, seed, octaves=2))
    return paint
