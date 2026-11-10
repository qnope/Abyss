"""The canvas an atlas tile is painted on, with numpy: pixel coordinates,
seeded noise that wraps around the tile's edges (a seamless tile repeats
without a seam), and soft-edged shapes. Every field is a (height, width)
array, row 0 at the top; x and y count pixels from the bottom left."""

import numpy


class Canvas:
    def __init__(self, width, height, seed):
        self.width, self.height, self.seed = width, height, seed
        self.rng = numpy.random.default_rng(seed)
        columns = numpy.arange(width) + 0.5
        rows = numpy.arange(height)[::-1] + 0.5
        self.x, self.y = numpy.meshgrid(columns, rows)
        self.s, self.t = self.x / width, self.y / height

    def _lattice(self, frequency):
        """Cells across and up for [frequency] cells across the shorter side."""
        short = min(self.width, self.height)
        return (max(1, round(frequency * self.width / short)),
                max(1, round(frequency * self.height / short)))

    def noise(self, frequency, seed=0):
        """Smooth value noise in [-1, 1], [frequency] bumps across the shorter
        side, wrapping around the edges."""
        across, up = self._lattice(frequency)
        values = numpy.random.default_rng((self.seed, seed, across)).uniform(-1, 1, (up, across))
        u, v = self.s * across, self.t * up
        i, j = numpy.floor(u).astype(int), numpy.floor(v).astype(int)
        fu, fv = _fade(u - i), _fade(v - j)
        i0, i1, j0, j1 = i % across, (i + 1) % across, j % up, (j + 1) % up
        low = values[j0, i0] * (1 - fu) + values[j0, i1] * fu
        high = values[j1, i0] * (1 - fu) + values[j1, i1] * fu
        return low * (1 - fv) + high * fv

    def fbm(self, frequency, octaves=3, gain=0.5, seed=0):
        """Fractal noise in [-1, 1]: [octaves] layers, each twice as fine."""
        total, weight, norm = numpy.zeros_like(self.s), 1.0, 0.0
        for octave in range(octaves):
            total += weight * self.noise(frequency * 2 ** octave, seed + 31 * octave)
            norm += weight
            weight *= gain
        return total / norm

    def _voronoi(self, frequency, seed):
        """Per pixel: the distances to the nearest and second nearest seed
        point (in cells) and a random value in [-1, 1] of the nearest's cell."""
        across, up = self._lattice(frequency)
        rng = numpy.random.default_rng((self.seed, seed, across, 7))
        jitter, ids = rng.uniform(0.1, 0.9, (up, across, 2)), rng.uniform(-1, 1, (up, across))
        u, v = self.s * across, self.t * up
        i, j = numpy.floor(u).astype(int), numpy.floor(v).astype(int)
        first = numpy.full(u.shape, 9.0)
        second, value = first.copy(), numpy.zeros_like(u)
        for di in (-1, 0, 1):
            for dj in (-1, 0, 1):
                ci, cj = (i + di) % across, (j + dj) % up
                d = numpy.hypot(i + di + jitter[cj, ci, 0] - u, j + dj + jitter[cj, ci, 1] - v)
                nearer = d < first
                second = numpy.where(nearer, first, numpy.minimum(second, d))
                value = numpy.where(nearer, ids[cj, ci], value)
                first = numpy.minimum(first, d)
        return first, second, value

    def cells(self, frequency, seed=0):
        """A random value in [-1, 1], the same over each cell: stones, scales."""
        return self._voronoi(frequency, seed)[2]

    def cracks(self, frequency, width=0.15, seed=0):
        """1 on the borders between cells, falling to 0 [width] inside them."""
        first, second, _ = self._voronoi(frequency, seed)
        return numpy.clip(1 - (second - first) / width, 0, 1)

    def pits(self, frequency, radius=0.35, seed=0):
        """1 at the heart of a round pit per cell, 0 beyond [radius]: pores."""
        first = self._voronoi(frequency, seed)[0]
        return numpy.clip(1 - first / radius, 0, 1)

    def box(self, x0, y0, x1, y1, soft=1.0):
        """1 inside the rectangle (pixels), fading over [soft] pixels."""
        inside = numpy.minimum(numpy.minimum(self.x - x0, x1 - self.x),
                               numpy.minimum(self.y - y0, y1 - self.y))
        return numpy.clip(inside / soft + 0.5, 0, 1)

    def disc(self, cx, cy, radius, soft=1.0):
        distance = numpy.hypot(self.x - cx, self.y - cy)
        return numpy.clip((radius - distance) / soft + 0.5, 0, 1)


def _fade(t):
    return t * t * t * (t * (t * 6 - 15) + 10)
