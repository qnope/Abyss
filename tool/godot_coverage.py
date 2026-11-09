#!/usr/bin/env python3
"""Line coverage of the Godot tests, written to coverage/godot/lcov.info.

    tool/godot_coverage.py [test file or folder ...]

Paths are as for tool/godot_test.sh. See tool/gdscript_coverage/README.md.
"""

import os
import sys

sys.dont_write_bytecode = True  # writes nothing in the repo but coverage/
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from gdscript_coverage.cli import main  # noqa: E402

if __name__ == "__main__":
    sys.exit(main())
