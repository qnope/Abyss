"""The layers of rock on the plateau's sides, from the lip down, and the
colours of the rock: each band has its own outline, a groove between two."""

import math

from catalog import colors
from workshop import noise
from workshop.colors import mix, scale

# (top, bottom, how far it stands out, colour), z in cells under the deck.
BANDS = (
    (-0.28, -0.56, 0.06, colors.BASALT),
    (-0.56, -0.82, -0.08, colors.OCHRE),
    (-0.82, -1.32, 0.02, colors.SLATE),
    (-1.32, -1.44, 0.13, colors.LIMESTONE),
    (-1.44, -1.98, -0.01, colors.BASALT_DEEP),
    (-1.98, -2.22, -0.1, colors.RUST),
    (-2.22, -2.52, 0.03, colors.SLATE),
)
GROOVE = 0.018


def tilt(x, y):
    """How far the strata rise or sink at plan point (x, y): the layers are
    folded, never level all round."""
    return 0.14 * noise.value((x * 0.18, y * 0.18), 61) + 0.04 * noise.value((x * 0.7, y * 0.7), 62)


def band_at(z):
    for index, band in enumerate(BANDS):
        if band[1] - GROOVE / 2 <= z <= band[0] + GROOVE / 2:
            return index
    return None


def rock_paint(seed, depth_fade=0.07):
    """The paint of the plateau's rock: the band's colour, mottled, darker
    deeper, with pale sediment on what faces up."""
    def paint(p, normal):
        z = p.z - tilt(p.x, p.y) if p.z < BANDS[0][0] else p.z
        index = band_at(z)
        if p.z > BANDS[0][0] + 0.02:
            base = _rim(p, seed)
        elif z < BANDS[-1][1]:
            layer = 0.5 + 0.5 * math.sin(p.z * 2.6 + 0.8 * noise.value(p * 0.4, seed + 4))
            base = mix(colors.BASALT_DEEP, colors.SLATE, max(0.0, layer - 0.55) * 1.8)
        elif index is None or _in_groove(z, index):
            base = colors.GROOVE
        else:
            base = BANDS[index][3]
        mottle = 1 + 0.22 * noise.fbm(p * 2.2, seed + 1, octaves=3)
        color = scale(base, mottle * max(0.35, 1 + p.z * depth_fade))
        dust = max(0.0, normal.z - 0.5) * 1.6 * (0.6 + 0.4 * noise.value(p * 3, seed + 2))
        return mix(color, colors.SEDIMENT, min(dust, 0.85))
    return paint


def _rim(p, seed):
    """The rim's top: rock under drifts of sediment, crusts of pink coralline
    algae and green mats."""
    base = mix(colors.RIM, colors.RIM_LIGHT, 0.5 + 0.5 * noise.fbm(p * 0.9, seed))
    drift = noise.fbm(p * 0.7, seed + 11)
    base = mix(base, colors.SAND, max(0.0, drift) * 0.9)
    crust = noise.fbm(p * 1.1, seed + 12)
    if crust > 0.35:
        base = mix(base, colors.CRUST, min(0.6, (crust - 0.35) * 2))
    mat = noise.fbm(p * 0.9, seed + 13)
    if mat > 0.4:
        base = mix(base, colors.MAT, min(0.5, (mat - 0.4) * 2))
    return base


def _in_groove(z, index):
    top, bottom = BANDS[index][0], BANDS[index][1]
    return z > top - GROOVE * 0.4 or z < bottom + GROOVE * 0.4
