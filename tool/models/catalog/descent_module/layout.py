"""Where the descent module's parts stand: the deck, the gantry's four leaning
legs, the well and the pod hanging over it. Plan in cells, Z up, the pad's
top at z = 0."""

DECK = 0.14  # the deck's top
FOOT, SPAN = 0.68, 0.46  # a leg's half-width at the deck and at the top
TOP = 1.62  # the gantry's top ring
HOUSING = (0.5, 0.18)  # the winch housing on it: side, height
POD = (0.46, 1.26, 0.34)  # the pod's lowest and highest z, its radius
WELL = (0.64, 0.46)  # the collar's outer and inner radius
SIGNS = ((1, 1), (-1, 1), (-1, -1), (1, -1))


def half_width(z):
    """A leg's distance from the axis along x and y at height [z]."""
    return FOOT + (SPAN - FOOT) * (z - DECK) / (TOP - DECK)


def leg(k, z):
    """The point of leg [k] at height [z]."""
    sx, sy = SIGNS[k]
    w = half_width(z)
    return (sx * w, sy * w, z)


def corners(z):
    """The four legs' points at height [z], in order round the gantry."""
    return [leg(k, z) for k in range(4)]
