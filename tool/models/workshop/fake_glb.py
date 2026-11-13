"""A glb written by hand for the tests of the glb readers: accessors packed one
after the other in the binary chunk, the meshes and the animations using them."""

import struct

from workshop.glb import GlbReport
from workshop.glb_accessors import FLOAT, FORMATS, WIDTHS

_USHORT = 5123
_TYPES = {"translation": "VEC3", "rotation": "VEC4", "scale": "VEC3"}


class FakeGlb:
    def __init__(self):
        self.document = {"bufferViews": [], "accessors": [], "nodes": [], "meshes": [],
                         "skins": [], "animations": []}
        self._binary = b""

    def floats(self, values, kind="VEC3"):
        """A new accessor of float [values], [kind] (VEC3...): its index."""
        return self._accessor(values, kind, FLOAT)

    def ushorts(self, values, kind="SCALAR", normalized=False):
        """A new accessor of unsigned short [values]: its index."""
        return self._accessor(values, kind, _USHORT, normalized)

    def mesh(self, *primitives):
        """A new mesh of [primitives], each {attribute or "indices": accessor}."""
        self.document["meshes"].append({"primitives": [
            {"attributes": {k: v for k, v in p.items() if k != "indices"},
             **({"indices": p["indices"]} if "indices" in p else {})} for p in primitives]})

    def skin(self, inverse_binds):
        """A new skin whose inverse bind matrices are the accessor [inverse_binds]."""
        self.document["skins"].append({"joints": [], "inverseBindMatrices": inverse_binds})

    def channel(self, animation, node, path, times, keys, interpolation="LINEAR"):
        """A channel of [animation] moving [path] of [node] through [keys] (one
        tuple per time of [times]), on new accessors: their indices."""
        start = self.floats(times, "SCALAR")
        return start, self.channel_of(animation, node, path, start,
                                      self.floats([v for key in keys for v in key], _TYPES[path]),
                                      interpolation)

    def channel_of(self, animation, node, path, times, keys, interpolation="LINEAR"):
        """A channel of [animation] on the accessors [times] and [keys]: [keys]."""
        target = self._node(node)
        named = [a for a in self.document["animations"] if a["name"] == animation]
        if not named:
            named = [{"name": animation, "channels": [], "samplers": []}]
            self.document["animations"].append(named[0])
        samplers = named[0]["samplers"]
        samplers.append({"input": times, "output": keys, "interpolation": interpolation})
        named[0]["channels"].append({"sampler": len(samplers) - 1,
                                     "target": {"node": target, "path": path}})
        return keys

    def report(self):
        return GlbReport(self.document, self._binary, ".")

    def _node(self, name):
        names = [node["name"] for node in self.document["nodes"]]
        if name not in names:
            self.document["nodes"].append({"name": name})
            names.append(name)
        return names.index(name)

    def _accessor(self, values, kind, component, normalized=False):
        data = struct.pack(f"<{len(values)}{FORMATS[component]}", *values)
        self.document["bufferViews"].append(
            {"buffer": 0, "byteOffset": len(self._binary), "byteLength": len(data)})
        self._binary += data + b"\0" * (-len(data) % 4)
        accessor = {"bufferView": len(self.document["bufferViews"]) - 1,
                    "count": len(values) // WIDTHS[kind], "type": kind,
                    "componentType": component}
        if normalized:
            accessor["normalized"] = True
        self.document["accessors"].append(accessor)
        return len(self.document["accessors"]) - 1
