"""Marks shared by the tiles: rivets, seams, drips and wear, as masks or
shading factors over a Canvas (pixels, y up)."""

import numpy


def edge_distance(canvas):
    """How far each pixel lies from the tile's nearest edge, in pixels."""
    return numpy.minimum(numpy.minimum(canvas.x, canvas.width - canvas.x),
                         numpy.minimum(canvas.y, canvas.height - canvas.y))


def seam(distance, width=2.0, bevel=5.0):
    """A dark joint [width] wide where [distance] is 0, then a worn, lighter
    bevel: the edges of a plate catch the light and lose their paint."""
    groove = numpy.clip(distance / width, 0, 1)
    shade = 0.32 + 0.68 * groove
    wear = 0.13 * numpy.clip(1 - (distance - width) / bevel, 0, 1) * (distance > width)
    return shade * (1 + wear)


def rivets(canvas, points, radius):
    """Domed rivets at [points]: lit from the top left, shadowed below."""
    shade = numpy.ones_like(canvas.x)
    for cx, cy in points:
        dx, dy = canvas.x - cx, canvas.y - cy
        d = numpy.hypot(dx, dy)
        head = numpy.clip(radius - d + 0.5, 0, 1)
        light = 1 + 0.45 * numpy.clip((-dx + dy) / radius, -1, 1)
        ring = numpy.clip(1 - numpy.abs(d - radius - 1.0) / 1.5, 0, 1)
        shadow = numpy.clip(1 - numpy.hypot(dx - radius * 0.4, dy + radius * 0.5) / (radius * 1.8), 0, 1)
        shade = shade * (1 - 0.35 * shadow * (1 - head)) * (1 - 0.3 * ring)
        shade = shade * (1 - head) + head * light * 0.9
    return shade


def drips(canvas, sources, length, width, seed=0):
    """Rust or grime running down from each source point: 1 at the source,
    fading below it, wavering with noise."""
    mask = numpy.zeros_like(canvas.x)
    waver = canvas.noise(3, seed=seed) * width * 0.6
    for cx, cy in sources:
        across = numpy.exp(-(((canvas.x - cx + waver) / width) ** 2))
        below = numpy.clip(1 - (cy - canvas.y) / length, 0, 1) * (canvas.y <= cy)
        mask = numpy.maximum(mask, across * below ** 1.5)
    return mask


def grime(canvas, amount, seed=0):
    """Dirt gathered toward the bottom of the tile, in patches: a factor."""
    patches = numpy.clip(0.55 + 0.6 * canvas.fbm(3, octaves=4, seed=seed), 0, 1)
    low = (1 - canvas.t) ** 2
    return 1 - amount * low * patches


def tint(shade, colour):
    """A grey [shade] field tinted by a linear [colour] where it applies."""
    return shade[..., None] * numpy.asarray(colour)[None, None, :]


def blend(base, colour, mask):
    """[base] (h, w, 3) turned to [colour] where [mask] (h, w) is 1."""
    return base * (1 - mask[..., None]) + numpy.asarray(colour) * mask[..., None]
