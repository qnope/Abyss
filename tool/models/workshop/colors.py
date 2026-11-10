"""Colours as linear RGB triples, the space of vertex colours and glTF factors."""


def linear(hex_color):
    """The linear RGB of an sRGB '#rrggbb' colour."""
    text = hex_color.lstrip("#")
    channels = [int(text[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in channels)


def mix(a, b, t):
    """From [a] at t = 0 to [b] at t = 1."""
    t = min(max(t, 0.0), 1.0)
    return tuple(x + (y - x) * t for x, y in zip(a, b))


def scale(color, factor):
    return tuple(c * factor for c in color)


def vary(color, rng, value=0.12, hue=0.04):
    """[color] a little lighter or darker, and a little warmer or cooler, by
    the next draws of [rng]: what tells two pieces of the same stuff apart."""
    light = 1 + rng.uniform(-value, value)
    shift = rng.uniform(-hue, hue)
    r, g, b = color
    return (r * light * (1 + shift), g * light, b * light * (1 - shift))
