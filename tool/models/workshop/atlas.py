"""A model's painted texture: a square PNG cut into a grid, each tile painted
by a script (panel lines, grime, pores, lit windows) and mapped on faces.
The glTF multiplies it by the vertex colours, so a tile near white keeps a
face's colour and adds its detail; one atlas serves all of a model's
textured materials, which keeps the textures and the draw calls few."""

import zlib
from dataclasses import dataclass
from typing import Callable

import numpy

from workshop import uv
from workshop.canvas import Canvas
from workshop.png import write_png

GUTTER = 4  # pixels around a tile, its edge repeated: no bleeding in the mipmaps
BLANK = "plain"  # the tile of the faces nothing maps: white


@dataclass(frozen=True)
class Tile:
    """[cells] is (column, row, width, height) in the atlas' grid, row 0 at
    the top. [paint](canvas) gives linear RGB, (height, width, 3) or a grey
    (height, width, 1). A [seamless] tile paints a wrapping pattern, stored
    2 x 2 so that faces can tile it (Atlas.tiled)."""

    cells: tuple
    paint: Callable
    seamless: bool = False


class Atlas:
    def __init__(self, size, grid, tiles, seed=0):
        if size & (size - 1) or size % grid:
            raise ValueError(f"an atlas is a power of two cut in whole cells, not {size} / {grid}")
        if BLANK not in tiles:
            raise ValueError(f"an atlas needs the white tile {BLANK!r}")
        self.size, self.grid, self.tiles, self.seed = size, grid, dict(tiles), seed
        taken = set()
        for name, tile in self.tiles.items():
            column, row, width, height = tile.cells
            cells = {(c, r) for c in range(column, column + width) for r in range(row, row + height)}
            if column + width > grid or row + height > grid or cells & taken:
                raise ValueError(f"the tile {name} is out of the grid or over another")
            taken |= cells

    def _pixels_of(self, name):
        """The tile's content rectangle in pixels: left, top, right, bottom."""
        column, row, width, height = self.tiles[name].cells
        cell = self.size // self.grid
        return (column * cell + GUTTER, row * cell + GUTTER,
                (column + width) * cell - GUTTER, (row + height) * cell - GUTTER)

    def rect(self, name):
        """The tile's content in UV space (v up): u0, v0, u1, v1."""
        left, top, right, bottom = self._pixels_of(name)
        return (left / self.size, 1 - bottom / self.size, right / self.size, 1 - top / self.size)

    def _to_uv(self, name, points):
        u0, v0, u1, v1 = self.rect(name)
        return [(u0 + s * (u1 - u0), v0 + t * (v1 - v0)) for s, t in points]

    def fit(self, name, up=(0, 0, 1)):
        """A mapping stretching each flat facet over the whole tile: a plate."""
        return lambda g: [self._to_uv(name, face) for face in uv.fit(g, up)]

    def planar(self, name, right, upward):
        """A mapping of the whole geometry over the tile, seen along a plane."""
        return lambda g: [self._to_uv(name, face) for face in uv.planar(g, right, upward)]

    def tiled(self, name, period):
        """A mapping repeating a seamless tile every [period] units."""
        if not self.tiles[name].seamless:
            raise ValueError(f"the tile {name} is not seamless")
        return lambda g: [self._to_uv(name, uv.tiled(g, i, period)) for i in range(len(g.faces))]

    def solid(self, name):
        """Every corner at the tile's centre: a flat colour of the atlas."""
        u0, v0, u1, v1 = self.rect(name)
        return lambda g: [[((u0 + u1) / 2, (v0 + v1) / 2)] * len(face) for face in g.faces]

    @property
    def blank(self):
        return self.solid(BLANK)

    def pixels(self):
        """The atlas as sRGB bytes, (size, size, 3), row 0 at the top."""
        image = numpy.ones((self.size, self.size, 3))
        for name, tile in self.tiles.items():
            left, top, right, bottom = self._pixels_of(name)
            seed = zlib.crc32(f"{self.seed}:{name}".encode())
            if tile.seamless:
                half = _painted(tile, Canvas((right - left) // 2, (bottom - top) // 2, seed))
                painted = numpy.tile(half, (2, 2, 1))
            else:
                painted = _painted(tile, Canvas(right - left, bottom - top, seed))
            padded = numpy.pad(painted, ((GUTTER, GUTTER), (GUTTER, GUTTER), (0, 0)), mode="edge")
            image[top - GUTTER:bottom + GUTTER, left - GUTTER:right + GUTTER] = \
                padded[:bottom - top + 2 * GUTTER, :right - left + 2 * GUTTER]
        return _srgb_bytes(image)

    def write(self, path):
        write_png(path, self.pixels())


def _painted(tile, canvas):
    colour = numpy.asarray(tile.paint(canvas), dtype=numpy.float64)
    if colour.ndim == 2:
        colour = colour[..., None]
    return numpy.broadcast_to(colour, (canvas.height, canvas.width, 3))


def _srgb_bytes(linear):
    c = numpy.clip(linear, 0, 1)
    srgb = numpy.where(c <= 0.0031308, c * 12.92, 1.055 * c ** (1 / 2.4) - 0.055)
    return numpy.round(srgb * 255).astype(numpy.uint8)
