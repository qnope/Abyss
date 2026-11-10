"""Compares the geometry of two glbs accessor by accessor: integers (indices)
must be equal, floats (positions, normals, colours, UVs) within a tolerance.

The same script gives float results that differ in their last bits from one
machine to another (the C maths library and SIMD code paths change), and a
glb stores float32, so a byte-for-byte hash would fail on another machine for
a geometry that is the same to the eye."""

import struct

_FORMATS = {5120: "b", 5121: "B", 5122: "h", 5123: "H", 5125: "I", 5126: "f"}
_WIDTHS = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT2": 4, "MAT3": 9, "MAT4": 16}
_FLOAT = 5126
_SHOWN = 5


def geometry_differences(expected, actual, tolerance=1e-4):
    """What differs between the reports [expected] and [actual], at most a few
    lines; an empty list when their geometry is the same."""
    ours = expected.document.get("accessors", [])
    theirs = actual.document.get("accessors", [])
    if len(ours) != len(theirs):
        return [f"{len(ours)} accessors against {len(theirs)}"]
    differences = []
    for index, (mine, other) in enumerate(zip(ours, theirs)):
        difference = _accessor_difference(index, expected, actual, mine, other, tolerance)
        if difference:
            differences.append(difference)
    return differences[:_SHOWN]


def _accessor_difference(index, expected, actual, mine, other, tolerance):
    layout = (mine["count"], mine["type"], mine["componentType"])
    if layout != (other["count"], other["type"], other["componentType"]):
        return (f"accessor {index}: {mine['count']} {mine['type']} against "
                f"{other['count']} {other['type']}")
    left, right = _values(expected, mine), _values(actual, other)
    exact = mine["componentType"] != _FLOAT
    apart = [abs(a - b) for a, b in zip(left, right) if (a != b if exact else abs(a - b) > tolerance)]
    if not apart:
        return None
    return (f"accessor {index}: {len(apart)} of {len(left)} values differ, "
            f"by up to {max(apart):.6g}")


def _values(report, accessor):
    """The components of [accessor], in order, as Python numbers."""
    view = report.document["bufferViews"][accessor["bufferView"]]
    form = _FORMATS[accessor["componentType"]]
    width = _WIDTHS[accessor["type"]]
    size = struct.calcsize("<" + form)
    stride = view.get("byteStride", size * width)
    start = view.get("byteOffset", 0) + accessor.get("byteOffset", 0)
    values = []
    for element in range(accessor["count"]):
        offset = start + element * stride
        values += struct.unpack_from(f"<{width}{form}", report.binary, offset)
    return values
