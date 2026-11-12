"""Tests of the command buildings (headquarters, laboratory, barracks, coral
citadel): three tiers that add up, each clearly more developed than the last,
the headquarters the most imposing of the island at its third tier, and the
barracks' machinery within the round plot it stands on at the back of the
army's parade ground (godot/presentation/world/parade/parade_barracks.gd)."""

import math
import struct
import unittest

from model_builds import built

# How much higher each tier makes a building at least: the citadel's second tier
# widens it (towers around a taller keep) rather than raising it.
GROWTH = {"headquarters": (0.05, 0.15), "laboratory": (0.05, 0.15), "barracks": (0.05, 0.15),
          "coral_citadel": (0.0, 0.15)}
COMMAND = {"headquarters": "Headquarters", "laboratory": "Laboratory", "barracks": "Barracks",
           "coral_citadel": "CoralCitadel"}
PLOT_RADIUS = 1.15  # ParadeBarracks: FOOTPRINT 2 cells * ParadeLayout.CELL 1.15 / 2
MACHINERY = ("_hull",)  # what the building is made of: the reef may grow past the plot


def _positions(report, path):
    """The (x, y, z) of every vertex of the mesh of the node at [path], in Godot's axes."""
    document = report.document
    node = report._nodes[report._paths[path]]
    result = []
    for primitive in document["meshes"][node["mesh"]]["primitives"]:
        accessor = document["accessors"][primitive["attributes"]["POSITION"]]
        view = document["bufferViews"][accessor["bufferView"]]
        start = view.get("byteOffset", 0) + accessor.get("byteOffset", 0)
        stride = view.get("byteStride", 12)
        for k in range(accessor["count"]):
            result.append(struct.unpack_from("<3f", report.binary, start + k * stride))
    return result


def _is_mesh(report, path):
    return "mesh" in report._nodes[report._paths[path]]


def _tier_vertices(report, root, tier, suffixes=("",)):
    """The vertices of what the game shows up to [tier]: the root's own meshes (the
    nodes the game turns, and the hull of the headquarters), then Tier1 to [tier]."""
    prefixes = [f"{root}/Tier{k}/" for k in range(1, tier + 1)]
    return [v for path in report.paths if path.endswith(suffixes) and (
        (path.count("/") == 1 and path != root and "Tier" not in path and _is_mesh(report, path))
        or any(path.startswith(prefix) and path.count("/") == 2 for prefix in prefixes))
        for v in _positions(report, path)]


class CommandTest(unittest.TestCase):
    def test_every_building_has_three_tiers_that_add_up(self):
        for name, root in COMMAND.items():
            report = built(name)[1]
            counts = [report.triangles_under(f"{root}/Tier{k}") for k in (1, 2, 3)]
            with self.subTest(name):
                self.assertTrue(all(count > 500 for count in counts), counts)
                self.assertLessEqual(sum(counts), report.triangles)
                self.assertEqual(report.triangles_under(root), report.triangles)

    def test_every_tier_stands_taller_than_the_one_before(self):
        for name, root in COMMAND.items():
            report = built(name)[1]
            tops = []
            for k in (1, 2, 3):
                tops.append(max(v[1] for v in _tier_vertices(report, root, k)))
            with self.subTest(name):
                self.assertGreaterEqual(tops[1], tops[0] + GROWTH[name][0])
                self.assertGreater(tops[2], tops[1] + GROWTH[name][1])

    def test_the_headquarters_is_the_most_imposing_at_its_third_tier(self):
        tops = {name: max(v[1] for v in _tier_vertices(built(name)[1], root, 3))
                for name, root in COMMAND.items()}
        others = max(top for name, top in tops.items() if name != "headquarters")
        self.assertGreater(tops["headquarters"], others * 1.3)
        low = max(v[1] for v in _tier_vertices(built("headquarters")[1], "Headquarters", 1))
        self.assertLess(low, tops["headquarters"] * 0.6)

    def test_the_barracks_stays_within_its_parade_plot_at_every_tier(self):
        report = built("barracks")[1]
        for tier in (1, 2, 3):
            with self.subTest(tier):
                reach = max(math.hypot(v[0], v[2]) for v in
                            _tier_vertices(report, "Barracks", tier, MACHINERY))
                self.assertLessEqual(reach, PLOT_RADIUS)

    def test_the_barracks_does_not_sink_below_its_pad(self):
        # On the parade ground it stands at the deck, the plot's disc rising 0.12 round it:
        # nothing may hang below its origin.
        report = built("barracks")[1]
        self.assertGreaterEqual(min(v[1] for v in _tier_vertices(report, "Barracks", 1)), -0.03)


if __name__ == "__main__":
    unittest.main()
