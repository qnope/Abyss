#!/usr/bin/env python3
"""Writes the Flutter theme's named colours as a JSON fixture for Godot.

    tool/flutter_palette.py

Reads the `static const` colours, numbers and colour lists of the Dart
theme classes below, and the colours of their `switch` arms (named after
the enum value), and writes them to FIXTURE, keyed by the GDScript class
that ports them and by the SCREAMING_SNAKE_CASE name of each constant.
Colours are "#AARRGGBB", as Dart writes them. The Godot test
presentation/ui/theme/tests/palette_test.gd compares each GDScript
constant to it: after a change of the Dart theme, regenerate the fixture
and that test fails until the port follows.
"""

import json
import os
import re
import sys

# The GDScript class porting each Dart theme file, in reading order: a
# file may refer to the colours of a file read before it.
SOURCES = {
    "AbyssColors": "lib/presentation/theme/abyss_colors.dart",
    "FactionColors": "lib/presentation/theme/faction_colors.dart",
    "AbyssArmyColors": "lib/presentation/theme/abyss_army_colors.dart",
    "AbyssSegmentedTheme": "lib/presentation/theme/abyss_segmented_theme.dart",
}
FIXTURE = "godot/presentation/ui/theme/tests/flutter_palette.json"

_CONST = re.compile(
    r"static const (Color |double |List<Color> )?(\w+)\s*=\s*([^;]+);")
_ARM = re.compile(
    r"\b[A-Z]\w*\.(\w+)\s*=>\s*(?:const\s+)?(Color\(0x[0-9A-Fa-f]{8}\)|[A-Z]\w*\.\w+)")
_COLOR = re.compile(r"Color\(0x([0-9A-Fa-f]{8})\)$")
_REFERENCE = re.compile(r"([A-Z]\w*)\.(\w+)$")
_NUMBER = re.compile(r"-?\d*\.?\d+$")


def parse(source, name, known):
    """The constants of the Dart class [name], in their order of appearance.

    [known] maps each class read before to its constants, for references.
    """
    source = re.sub(r"//[^\n]*", "", source)
    values = {}
    for match in _CONST.finditer(source):
        kind, field, text = match.groups()
        value = _value(text.strip(), name, values, known)
        if value is None and kind:
            raise ValueError(f"{name}.{field}: cannot read {text.strip()!r}")
        if value is not None:
            values[snake(field)] = value
    for match in _ARM.finditer(source):
        values[snake(match.group(1))] = _value(match.group(2), name, values, known)
    return values


def snake(name):
    """abyssBlack -> ABYSS_BLACK."""
    return re.sub(r"(?<=[a-z0-9])(?=[A-Z])", "_", name).upper()


def _value(text, name, values, known):
    color = _COLOR.match(text)
    if color:
        return "#" + color.group(1).upper()
    if _NUMBER.match(text):
        return float(text)
    if text.startswith("[") and text.endswith("]"):
        items = [item.strip() for item in text[1:-1].split(",") if item.strip()]
        return [_value(item, name, values, known) for item in items]
    reference = _REFERENCE.match(text)
    if reference:
        owner, field = reference.groups()
        table = values if owner == name else known.get(owner, {})
        if snake(field) not in table:
            raise ValueError(f"{name}: unknown colour {text}")
        return table[snake(field)]
    return None


def read_palettes(repo):
    """Every class of SOURCES, read from the Dart files under [repo]."""
    palettes = {}
    for name, path in SOURCES.items():
        with open(os.path.join(repo, path), encoding="utf-8") as dart:
            palettes[name] = parse(dart.read(), name, palettes)
    return palettes


def main():
    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    with open(os.path.join(repo, FIXTURE), "w", encoding="utf-8") as out:
        json.dump(read_palettes(repo), out, indent=2)
        out.write("\n")
    print(f"wrote {FIXTURE}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
