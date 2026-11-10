"""Writes and reads 8-bit RGB PNG files with the stdlib and numpy: the same
pixels always give the same bytes, so a committed texture can be compared
with the one its script paints."""

import struct
import zlib

import numpy

_SIGNATURE = b"\x89PNG\r\n\x1a\n"
_UP = 2  # each row stored as its difference with the row above


def write_png(path, pixels):
    """Writes [pixels], a (height, width, 3) array of uint8, to [path]."""
    if pixels.dtype != numpy.uint8 or pixels.ndim != 3 or pixels.shape[2] != 3:
        raise ValueError("write_png takes a (height, width, 3) array of uint8")
    height, width, _ = pixels.shape
    rows = pixels.reshape(height, width * 3)
    above = numpy.vstack([numpy.zeros((1, width * 3), numpy.uint8), rows[:-1]])
    filtered = numpy.hstack([numpy.full((height, 1), _UP, numpy.uint8), rows - above])
    header = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    with open(path, "wb") as file:
        file.write(_SIGNATURE + _chunk(b"IHDR", header)
                   + _chunk(b"IDAT", zlib.compress(filtered.tobytes(), 9)) + _chunk(b"IEND", b""))


def read_png(path):
    """The pixels of a PNG this module wrote, as a (height, width, 3) array."""
    with open(path, "rb") as file:
        data = file.read()
    if data[:8] != _SIGNATURE:
        raise ValueError(f"{path} is not a PNG file")
    offset, chunks = 8, {}
    while offset < len(data):
        length, kind = struct.unpack_from(">I4s", data, offset)
        chunks[kind] = chunks.get(kind, b"") + data[offset + 8:offset + 8 + length]
        offset += 12 + length
    width, height = struct.unpack_from(">II", chunks[b"IHDR"])
    raw = numpy.frombuffer(zlib.decompress(chunks[b"IDAT"]), numpy.uint8)
    filtered = raw.reshape(height, width * 3 + 1)
    if numpy.any(filtered[:, 0] != _UP):
        raise ValueError(f"{path} was not written by write_png")
    rows = numpy.cumsum(filtered[:, 1:].astype(numpy.uint32), axis=0) % 256
    return rows.astype(numpy.uint8).reshape(height, width, 3)


def _chunk(kind, payload):
    return (struct.pack(">I", len(payload)) + kind + payload
            + struct.pack(">I", zlib.crc32(kind + payload)))
