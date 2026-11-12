"""The loops the map's creatures share: they close on themselves and the wave
runs along a chain, each bone late and wider than the one before."""

import unittest

from catalog.ambient import SAMPLES, chain_swing, swing


class AmbientTest(unittest.TestCase):
    def test_a_swing_ends_where_it_starts(self):
        keys = swing(30, (10, 0, 4), (0, 0, 0.1), phase=0.2)
        self.assertEqual(keys[0].frame, 0)
        self.assertEqual(keys[-1].frame, 30)
        self.assertEqual(keys[-1].rotation, keys[0].rotation)
        self.assertEqual(keys[-1].location, keys[0].location)
        self.assertEqual(len(keys), SAMPLES + 1)

    def test_a_swing_is_a_sine_of_its_amplitude(self):
        keys = swing(32, (8, 0, 0))
        self.assertEqual(keys[0].rotation, (0.0, 0.0, 0.0))
        self.assertAlmostEqual(keys[SAMPLES // 4].rotation[0], 8.0, places=3)
        self.assertAlmostEqual(keys[3 * SAMPLES // 4].rotation[0], -8.0, places=3)

    def test_a_chain_swings_late_and_wider_along_its_bones(self):
        tracks = chain_swing(["A", "B", "C"], 40, (0, 0, 10), 0.1, 1.5, location=(0, 0, 0.2))
        peaks = [max(abs(key.rotation[2]) for key in tracks[name]) for name in "ABC"]
        self.assertLess(peaks[0], peaks[1])
        self.assertLess(peaks[1], peaks[2])
        self.assertEqual([key.location for key in tracks["B"]], [(0, 0, 0)] * (SAMPLES + 1))
        self.assertNotEqual(tracks["A"][1].location, (0, 0, 0))
        self.assertNotEqual(tracks["A"][1].rotation, tracks["B"][1].rotation)

    def test_a_chain_adds_to_the_tracks_it_is_given(self):
        tracks = {"Body": swing(20, (1, 0, 0))}
        self.assertIs(chain_swing(["T"], 20, (0, 1, 0), 0.1, tracks=tracks), tracks)
        self.assertEqual(sorted(tracks), ["Body", "T"])


if __name__ == "__main__":
    unittest.main()
