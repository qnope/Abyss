"""The catalog's models built once per test run, in a temporary folder."""

import atexit
import os
import shutil
import tempfile

from build import build_model

_folder = tempfile.mkdtemp(prefix="models_test_")
atexit.register(shutil.rmtree, _folder, True)
_built = {}


def built(name):
    """The path and the report of the model [name], built at the first call."""
    if name not in _built:
        _built[name] = build_model(name, _folder)
    return _built[name]


def rebuilt(name):
    """The model [name] built once more, in a folder of its own."""
    folder = tempfile.mkdtemp(prefix="models_test_again_", dir=_folder)
    return build_model(name, folder)


def committed(name):
    """The path of the model [name] in the game's assets."""
    return os.path.join(os.path.dirname(__file__), "..", "..", "godot", "assets", "models",
                        f"{name}.glb")
