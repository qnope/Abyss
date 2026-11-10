"""Links a model's atlas into its glb, with the stdlib only. Blender exports
the faces' UVs but no texture (the atlas is painted by script, not by
Blender's nodes): this names the PNG next to the glb as the base colour of
the textured materials, and as the emission of the glowing ones, so the
game imports it as a texture of its own, compressed for the GPU."""

import json
import struct

_JSON = 0x4E4F534A
_LINEAR, _LINEAR_MIPMAP_LINEAR, _CLAMP = 9729, 9987, 33071


def link_atlas(path, uri, textured, emissive):
    """Rewrites the glb at [path]: the materials named in [textured] take the
    image [uri] as base colour, those in [emissive] as emission too."""
    with open(path, "rb") as file:
        data = file.read()
    length = struct.unpack_from("<I", data, 12)[0]
    document, rest = json.loads(data[20:20 + length]), data[20 + length:]
    document["images"] = [{"uri": uri, "mimeType": "image/png"}]
    document["samplers"] = [{"magFilter": _LINEAR, "minFilter": _LINEAR_MIPMAP_LINEAR,
                             "wrapS": _CLAMP, "wrapT": _CLAMP}]
    document["textures"] = [{"sampler": 0, "source": 0}]
    for material in document.get("materials", []):
        if material.get("name") in textured:
            material.setdefault("pbrMetallicRoughness", {})["baseColorTexture"] = {"index": 0}
            if material["name"] in emissive:
                material["emissiveTexture"] = {"index": 0}
    text = json.dumps(document, separators=(",", ":")).encode()
    text += b" " * (-len(text) % 4)
    header = struct.pack("<III", 0x46546C67, 2, 20 + len(text) + len(rest))
    with open(path, "wb") as file:
        file.write(header + struct.pack("<II", len(text), _JSON) + text + rest)
