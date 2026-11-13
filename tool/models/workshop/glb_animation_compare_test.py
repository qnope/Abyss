"""Tests of the comparison of two glbs' animations, channel by channel."""

import unittest

from workshop.fake_glb import FakeGlb
from workshop.glb_compare import geometry_differences

TIMES = (0, 0.5, 1)
SWAY = [(0, 0, 0), (0, 0.5, 0), (0, 0, 0)]
STILL = [(0, 1, 0), (0, 1, 0)]


def _sway(keys=SWAY, times=TIMES, interpolation="LINEAR", path="translation"):
    glb = FakeGlb()
    glb.channel("idle", "Body", path, times, keys, interpolation)
    return glb.report()


def _two_still_channels(shared):
    """Two nodes held still at the same place by one animation, as the exporter
    writes them on one accessor when they are equal to the last bit."""
    glb = FakeGlb()
    times, keys = glb.channel("idle", "Head", "translation", (0, 1), STILL, "STEP")
    if shared:
        glb.channel_of("idle", "Tail", "translation", times, keys, "STEP")
    else:
        glb.channel("idle", "Tail", "translation", (0, 1), STILL, "STEP")
    glb.channel("idle", "Body", "translation", TIMES, SWAY)
    return glb.report()


class GlbAnimationCompareTest(unittest.TestCase):
    def test_the_same_animation_has_no_difference(self):
        self.assertEqual(geometry_differences(_sway(), _sway()), [])

    def test_a_still_key_shared_by_two_channels_is_the_same_as_two_copies(self):
        # What failed on Ubuntu 26.04: the same animations, but the still
        # channels the exporter shared there were not shared where they were
        # built, so every accessor after them moved by one.
        self.assertEqual(geometry_differences(_two_still_channels(True),
                                              _two_still_channels(False)), [])
        self.assertEqual(geometry_differences(_two_still_channels(False),
                                              _two_still_channels(True)), [])

    def test_keys_apart_by_less_than_the_tolerance_are_the_same(self):
        nudged = [(0, 0, 0), (0, 0.50001, 0), (0, 0, 0)]
        self.assertEqual(geometry_differences(_sway(), _sway(nudged), 1e-4), [])

    def test_keys_apart_by_more_than_the_tolerance_are_named(self):
        higher = [(0, 0, 0), (0, 0.6, 0), (0, 0, 0)]
        differences = geometry_differences(_sway(), _sway(higher), 1e-4)
        self.assertEqual(len(differences), 1)
        self.assertIn("animation idle Body translation", differences[0])
        self.assertIn("by up to 0.1", differences[0])

    def test_a_still_channel_kept_whole_or_cut_to_its_ends_is_the_same(self):
        # The exporter keeps only the first and the last key of a channel
        # that moves by less than 1e-4, which the last bits can decide.
        still = [(0, 1, 0)] * 3
        nearly = [(0, 1, 0), (0, 1.00002, 0), (0, 1, 0)]
        self.assertEqual(geometry_differences(_sway(nearly), _sway(still[:2], (0, 1))), [])

    def test_a_curve_cut_to_its_ends_is_named(self):
        differences = geometry_differences(_sway(), _sway(SWAY[::2], (0, 1)))
        self.assertIn("animation idle Body translation", differences[0])

    def test_steps_and_lines_through_the_same_keys_are_named(self):
        differences = geometry_differences(_sway(), _sway(interpolation="STEP"))
        self.assertIn("animation idle Body translation", differences[0])

    def test_keys_at_other_times_are_named(self):
        differences = geometry_differences(_sway(), _sway(times=(0, 0.25, 1)))
        self.assertIn("animation idle Body translation", differences[0])

    def test_rotations_are_compared(self):
        turn = [(0, 0, 0, 1), (0, 0.38, 0, 0.92), (0, 0, 0, 1)]
        more = [(0, 0, 0, 1), (0, 0.5, 0, 0.87), (0, 0, 0, 1)]
        self.assertEqual(geometry_differences(_sway(turn, path="rotation"),
                                              _sway(turn, path="rotation")), [])
        self.assertIn("animation idle Body rotation",
                      geometry_differences(_sway(turn, path="rotation"),
                                           _sway(more, path="rotation"))[0])

    def test_a_missing_channel_is_named(self):
        glb = FakeGlb()
        glb.channel("idle", "Body", "scale", TIMES, SWAY)
        self.assertEqual(geometry_differences(_sway(), glb.report()),
                         ["animation idle Body translation: missing",
                          "animation idle Body scale: unexpected"])


if __name__ == "__main__":
    unittest.main()
