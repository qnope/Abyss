"""Compares the geometry of two glbs: the accessors of each mesh primitive and
skin, met by what uses them, integers (indices) equal, floats (positions,
normals, UVs) within a tolerance and normalised integers (vertex colours)
within one occlusion ray for a rare few; then the animations, channel by
channel (workshop/glb_animation_compare.py).

The same script gives float results that differ in their last bits from one
machine to another (the C maths library and SIMD code paths change), so a
byte-for-byte hash would fail on another machine for a geometry that is the
same to the eye. In the colours the last bit can flip an occlusion ray that
grazes an edge: a handful of corners among a hundred thousand then change by
up to one ray's share of the light. And the exporter writes data equal to the
last bit once, for every user: which accessors are shared, so how many there
are and in which order, depends on the machine too (Ubuntu 26.04's against
24.04's), hence accessors compared by what uses them, never by their index."""

import struct

from workshop.glb_accessors import FLOAT, FORMATS, accessor_values
from workshop.glb_animation_compare import animation_differences, missing_and_unexpected

_SHOWN = 5
# A colour may be off by one occlusion ray of the fewest a model casts...
_RAY = 1 / 16
# ...for this share of an accessor's values at most (and always for one).
_RARE = 1 / 2000


def geometry_differences(expected, actual, tolerance=1e-4):
    """What differs between the reports [expected] and [actual], at most a few
    lines; an empty list when their geometry and animations are the same."""
    ours, theirs = _uses(expected), _uses(actual)
    differences = missing_and_unexpected(ours, theirs)
    for use, index in ours.items():
        if use in theirs:
            difference = _accessor_difference(expected, actual, index, theirs[use], tolerance)
            if difference:
                differences.append(f"{use}: {difference}")
    differences += animation_differences(expected, actual, tolerance)
    return differences[:_SHOWN]


def _uses(report):
    """The accessors of the meshes and the skins of [report], by what uses them."""
    uses = {}
    for m, mesh in enumerate(report.document.get("meshes", [])):
        for p, primitive in enumerate(mesh["primitives"]):
            for attribute, index in primitive["attributes"].items():
                uses[f"mesh {m} primitive {p} {attribute}"] = index
            if "indices" in primitive:
                uses[f"mesh {m} primitive {p} indices"] = primitive["indices"]
            for t, target in enumerate(primitive.get("targets", [])):
                for attribute, index in target.items():
                    uses[f"mesh {m} primitive {p} target {t} {attribute}"] = index
    for s, skin in enumerate(report.document.get("skins", [])):
        if "inverseBindMatrices" in skin:
            uses[f"skin {s} inverse binds"] = skin["inverseBindMatrices"]
    return uses


def _accessor_difference(expected, actual, ours, theirs, tolerance):
    mine = expected.document["accessors"][ours]
    other = actual.document["accessors"][theirs]
    layout = (mine["count"], mine["type"], mine["componentType"])
    if layout != (other["count"], other["type"], other["componentType"]):
        return f"{mine['count']} {mine['type']} against {other['count']} {other['type']}"
    left, right = accessor_values(expected, ours), accessor_values(actual, theirs)
    limit = tolerance if mine["componentType"] == FLOAT else 0
    apart = [abs(a - b) for a, b in zip(left, right) if abs(a - b) > limit]
    if not apart or (mine.get("normalized") and _rare_rays(apart, len(left), mine)):
        return None
    return f"{len(apart)} of {len(left)} values differ, by up to {max(apart):.6g}"


def _rare_rays(apart, count, accessor):
    """Whether the differences [apart], among [count] normalised values, are
    only a rare few within one occlusion ray."""
    full = 2 ** (8 * struct.calcsize("<" + FORMATS[accessor["componentType"]])) - 1
    return len(apart) <= max(1, count * _RARE) and max(apart) <= full * _RAY
