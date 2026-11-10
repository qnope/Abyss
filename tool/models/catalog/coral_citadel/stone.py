"""The citadel's grown stone: shapes cut fine and swollen by noise, painted
as the rampart's reef rock, darker at the foot, its tops greening."""

from mathutils import Vector

from catalog import colors
from catalog.base_rampart.masonry import coral_stone
from workshop import noise
from workshop.colors import mix, scale


def grown(geometry, seed, amount=0.03, longest=0.12):
    """[geometry] cut in a fine grid and swollen by smooth noise."""
    geometry.subdivide(longest)
    geometry.displace(lambda p: noise.vector(p * 3.4, seed) * amount
                      + noise.vector(p * 9.0, seed + 5) * amount * 0.3)
    return geometry


def stone(rng, seed, moss=0.35):
    """Reef rock, with a living crust (rose and green) on what faces up."""
    rock = coral_stone(rng, seed)

    def paint(p, normal):
        colour = rock(p, normal)
        crust = max(0.0, normal.z - 0.5) * 2 * (0.5 + 0.5 * noise.fbm(p * 5, seed + 3))
        tint = colors.CORAL_STONE_ROSE if noise.value(p * 2, seed) > 0 else colors.MAT
        return mix(colour, tint, crust * moss)
    return paint


def living(seed, low, high):
    """Living coral, deep red at [low] to pink and a pale rim at [high]."""
    def paint(p, normal):
        t = max(0.0, min(1.0, (p.z - low) / (high - low)))
        colour = mix(colors.CORAL_DEEP, colors.CORAL_PINK, t * 1.4)
        colour = mix(colour, colors.SHELL, max(0.0, t - 0.75) * 2.4)
        return scale(colour, 1 + 0.2 * noise.fbm(p * 6, seed, octaves=2))
    return paint


def out_of(x, y):
    """The horizontal unit vector from the centre through (x, y)."""
    v = Vector((x, y, 0))
    return v.normalized() if v.length else Vector((1, 0, 0))
