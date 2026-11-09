"""Tests of flutter_palette.py: python3 -m unittest discover -s tool -p '*_test.py'"""

import json
import os
import unittest

import flutter_palette

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

SAMPLE = """
import 'package:flutter/material.dart';

abstract final class SampleColors {
  // Deep sea backgrounds
  static const Color abyssBlack = Color(0xFF0A0E1A);
  static const Color plainBlue = Color(0x6642a5f5); // lower case
  static const Color finial = SampleColors.abyssBlack;
  static const tray = Color(0xEB0D1B2A);
  static const double fogOpacity = 0.7;
  static const double lockedOpacity = .45;
  static const height = 40.0;
  static const List<Color> poleMetal = [
    Color(0xFFCFD8DC),
    SampleColors.plainBlue,
  ];
  static const label = TextStyle(fontSize: 13, color: Color(0xFF9FB8D6));
  static final Color computed = abyssBlack.withValues(alpha: 0.5);
  static Color of(UnitType type) => switch (type) {
        UnitType.scout => SampleColors.plainBlue,
        UnitType.domeBreaker => const Color(0xFFFF9100),
      };
}
"""


class ParseTest(unittest.TestCase):
    def setUp(self):
        self.palette = flutter_palette.parse(SAMPLE, "SampleColors", {})

    def test_reads_colors_as_argb_in_dart_order(self):
        self.assertEqual(
            list(self.palette)[:4],
            ["ABYSS_BLACK", "PLAIN_BLUE", "FINIAL", "TRAY"],
        )
        self.assertEqual(self.palette["ABYSS_BLACK"], "#FF0A0E1A")
        self.assertEqual(self.palette["PLAIN_BLUE"], "#6642A5F5")
        self.assertEqual(self.palette["TRAY"], "#EB0D1B2A")

    def test_resolves_a_reference_to_another_constant(self):
        self.assertEqual(self.palette["FINIAL"], "#FF0A0E1A")

    def test_reads_numbers_and_lists(self):
        self.assertEqual(self.palette["FOG_OPACITY"], 0.7)
        self.assertEqual(self.palette["LOCKED_OPACITY"], 0.45)
        self.assertEqual(self.palette["HEIGHT"], 40.0)
        self.assertEqual(self.palette["POLE_METAL"], ["#FFCFD8DC", "#6642A5F5"])

    def test_names_the_switch_arms_after_their_enum_value(self):
        self.assertEqual(self.palette["SCOUT"], "#6642A5F5")
        self.assertEqual(self.palette["DOME_BREAKER"], "#FFFF9100")

    def test_skips_text_styles_and_computed_colors(self):
        self.assertNotIn("LABEL", self.palette)
        self.assertNotIn("COMPUTED", self.palette)

    def test_resolves_a_constant_of_a_class_read_before(self):
        other = "class B {\n  static const Color c = SampleColors.tray;\n}"
        known = {"SampleColors": self.palette}
        self.assertEqual(flutter_palette.parse(other, "B", known), {"C": "#EB0D1B2A"})

    def test_fails_on_a_typed_color_it_cannot_read(self):
        source = "class B {\n  static const Color c = Color.fromARGB(1, 2, 3, 4);\n}"
        with self.assertRaisesRegex(ValueError, "B.c"):
            flutter_palette.parse(source, "B", {})

    def test_fails_on_an_unknown_reference(self):
        source = "class B {\n  static const Color c = Nowhere.dark;\n}"
        with self.assertRaisesRegex(ValueError, "Nowhere.dark"):
            flutter_palette.parse(source, "B", {})


class RepoTest(unittest.TestCase):
    def setUp(self):
        self.palettes = flutter_palette.read_palettes(REPO)

    def test_reads_the_flutter_theme(self):
        colors = self.palettes["AbyssColors"]
        self.assertEqual(colors["ABYSS_BLACK"], "#FF0A0E1A")
        self.assertEqual(colors["PLAIN_BLUE"], "#6642A5F5")
        self.assertEqual(colors["FOG_OPACITY"], 0.7)
        self.assertEqual(len(self.palettes["FactionColors"]), 10)
        army = self.palettes["AbyssArmyColors"]
        self.assertEqual(army["SCOUT"], colors["BIOLUM_BLUE"])
        self.assertEqual(army["FINIAL"], colors["ENERGY_YELLOW"])
        self.assertEqual(len(army["POLE_METAL"]), 3)
        self.assertEqual(self.palettes["AbyssSegmentedTheme"]["TRAY_EDGE"],
                         colors["SURFACE_LIGHT"])

    def test_the_committed_fixture_is_up_to_date(self):
        with open(os.path.join(REPO, flutter_palette.FIXTURE), encoding="utf-8") as f:
            committed = json.load(f)
        self.assertEqual(
            committed, self.palettes,
            "the Dart theme changed: run tool/flutter_palette.py, then port it",
        )


if __name__ == "__main__":
    unittest.main()
