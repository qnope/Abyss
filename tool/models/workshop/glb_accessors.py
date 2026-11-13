"""Reads the values of a glb's accessors, with the stdlib only."""

import struct

FORMATS = {5120: "b", 5121: "B", 5122: "h", 5123: "H", 5125: "I", 5126: "f"}
WIDTHS = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT2": 4, "MAT3": 9, "MAT4": 16}
FLOAT = 5126


def accessor_values(report, index):
    """The components of the accessor [index] of [report], in order, as Python numbers."""
    accessor = report.document["accessors"][index]
    view = report.document["bufferViews"][accessor["bufferView"]]
    form = FORMATS[accessor["componentType"]]
    width = WIDTHS[accessor["type"]]
    size = struct.calcsize("<" + form)
    stride = view.get("byteStride", size * width)
    start = view.get("byteOffset", 0) + accessor.get("byteOffset", 0)
    values = []
    for element in range(accessor["count"]):
        offset = start + element * stride
        values += struct.unpack_from(f"<{width}{form}", report.binary, offset)
    return values


def accessor_keys(report, index):
    """The elements of the accessor [index] of [report]: tuples of its components."""
    values = accessor_values(report, index)
    width = WIDTHS[report.document["accessors"][index]["type"]]
    return [tuple(values[i:i + width]) for i in range(0, len(values), width)]
