"""Reads what the tests and the budgets need from a glb, with the stdlib only:
the node tree, the triangles, the materials, the images and a hash of the
geometry."""

import hashlib
import json
import os
import struct

_MAGIC = 0x46546C67
_JSON = 0x4E4F534A
_BIN = 0x004E4942
_TRIANGLES = 4


class GlbReport:
    """What a glb holds, from its JSON chunk and its binary chunk."""

    def __init__(self, document, binary, folder):
        self._document = document
        self._nodes = document.get("nodes", [])
        self._paths = {}
        self._index_paths(document)
        self.binary = binary
        self.images = [_image_size(image, document, binary, folder)
                       for image in document.get("images", [])]

    def _index_paths(self, document):
        scene = document.get("scenes", [{}])[document.get("scene", 0)]
        self.roots = [self._nodes[i]["name"] for i in scene.get("nodes", [])]
        pending = [(i, self._nodes[i]["name"]) for i in reversed(scene.get("nodes", []))]
        while pending:
            index, path = pending.pop()
            self._paths[path] = index
            pending += [(child, f"{path}/{self._nodes[child]['name']}")
                        for child in reversed(self._nodes[index].get("children", []))]

    @property
    def paths(self):
        """Every node, as the names from a root down to it joined by '/'."""
        return list(self._paths)

    @property
    def document(self):
        """The glb's JSON chunk."""
        return self._document

    @property
    def materials(self):
        return [material.get("name", "") for material in self._document.get("materials", [])]

    @property
    def bones(self):
        """The joints of the skins, each counted once."""
        return len({joint for skin in self._document.get("skins", []) for joint in skin["joints"]})

    @property
    def animations(self):
        """The names of the animations."""
        return [animation.get("name", "") for animation in self._document.get("animations", [])]

    @property
    def keyframes(self):
        """The keyframes of the animations: the times of every sampler."""
        accessors = self._document.get("accessors", [])
        return sum(accessors[sampler["input"]]["count"]
                   for animation in self._document.get("animations", [])
                   for sampler in animation["samplers"])

    @property
    def triangles(self):
        """The triangles drawn, a mesh counted once per node showing it."""
        return sum(self.triangles_under(root) for root in self.roots)

    def triangles_under(self, path):
        """The triangles of the node at [path] and of the nodes under it."""
        return sum(self._mesh_triangles(self._nodes[self._paths[p]])
                   for p in self._paths if p == path or p.startswith(path + "/"))

    @property
    def draw_calls(self):
        """The primitives drawn, a mesh counted once per node showing it."""
        meshes = self._document.get("meshes", [])
        return sum(len(meshes[self._nodes[i]["mesh"]]["primitives"])
                   for i in self._paths.values() if "mesh" in self._nodes[i])

    def translation(self, path):
        return tuple(self._nodes[self._paths[path]].get("translation", (0, 0, 0)))

    @property
    def bounds(self):
        """The lowest and highest corner of every mesh's positions, in mesh space."""
        return self._box(self._document.get("meshes", []))

    def bounds_of(self, path):
        """The lowest and highest corner of the mesh of the node at [path], in its space."""
        return self._box([self._document["meshes"][self._nodes[self._paths[path]]["mesh"]]])

    def _box(self, meshes):
        boxes = [self._document["accessors"][primitive["attributes"]["POSITION"]]
                 for mesh in meshes for primitive in mesh["primitives"]]
        low = tuple(min(box["min"][axis] for box in boxes) for axis in range(3))
        high = tuple(max(box["max"][axis] for box in boxes) for axis in range(3))
        return low, high

    @property
    def geometry_hash(self):
        """A hash of the binary chunk: the same for the same geometry, whatever
        the exporter writes in the JSON about itself."""
        return hashlib.sha256(self.binary).hexdigest()

    def _mesh_triangles(self, node):
        if "mesh" not in node:
            return 0
        accessors = self._document["accessors"]
        total = 0
        for primitive in self._document["meshes"][node["mesh"]]["primitives"]:
            if primitive.get("mode", _TRIANGLES) != _TRIANGLES:
                continue
            source = primitive.get("indices", primitive["attributes"]["POSITION"])
            total += accessors[source]["count"] // 3
        return total


def read_glb(path):
    """The report of the glb at [path]; a ValueError when it is no glb 2."""
    with open(path, "rb") as file:
        data = file.read()
    if len(data) < 20 or struct.unpack_from("<II", data) != (_MAGIC, 2):
        raise ValueError(f"{path} is not a glb 2.0 file")
    document, binary, offset = None, b"", 12
    while offset < len(data):
        length, kind = struct.unpack_from("<II", data, offset)
        chunk = data[offset + 8:offset + 8 + length]
        if kind == _JSON:
            document = json.loads(chunk)
        elif kind == _BIN:
            binary = chunk
        offset += 8 + length
    if document is None:
        raise ValueError(f"{path} has no JSON chunk")
    return GlbReport(document, binary, os.path.dirname(path))


def _image_size(image, document, binary, folder):
    if "uri" in image:
        with open(os.path.join(folder, image["uri"]), "rb") as file:
            header = file.read(24)
    else:
        view = document["bufferViews"][image["bufferView"]]
        start = view.get("byteOffset", 0)
        header = binary[start:start + 24]
    if header[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("only PNG images are read")
    return struct.unpack(">II", header[16:24])
