"""What a content of the map stands on: a low bank of silt, sand or rock that
ties it to the floor, its edge a little ragged, and a few small rocks."""

from catalog.parts.deep import swell
from workshop import noise, sweep
from workshop.colors import linear, scale

SILT = linear("#cfae72")
ROCK = linear("#6d7686")
DARK_ROCK = linear("#3e4656")


def bank(into, atlas, radius=0.5, top=0.05, colour=SILT, tile="stone", seed=3, period=0.5, sides=18):
    """A bank [radius] wide and [top] high, painted [colour], mapped with the
    seamless [tile] of the atlas. It sinks a little under the floor."""
    mound = swell(sweep.lathe([(radius, -0.03), (radius * 0.95, 0.01), (radius * 0.78, top * 0.8),
                               (radius * 0.4, top), (0.0, top)], sides=sides), seed, 0.02, 0.1)

    def paint(p, normal):
        return scale(colour, 0.85 + 0.2 * noise.fbm(p * 5, seed + 1, octaves=2))
    into.add(mound, "reef", paint, atlas.tiled(tile, period)(mound))
    return mound
