"""Tests of the island's plan: the slots of the Flutter game, walkways that
join them without running under a pad, and the free ground for the decor."""

import math
import unittest

from catalog.base_island import layout

# The slots of the base of the Flutter game, which the island keeps:
# (u, v, footprint) of each building, as that version's base_layout.dart gave them.
FLUTTER_SLOTS = {
    "volcanic_kernel": (2.0, 2.0, 2),
    "laboratory": (2.2, 6.6, 2),
    "solar_panel": (6.6, 2.2, 2),
    "coral_mine": (3.7, 9.0, 2),
    "headquarters": (6.4, 6.4, 3),
    "algae_farm": (9.0, 3.7, 2),
    "barracks": (7.4, 10.4, 2),
    "ore_extractor": (10.4, 7.4, 2),
    "pressure_capsule": (4.6, 11.0, 2),
    "descent_module": (11.0, 4.6, 2),
    "coral_citadel": (10.2, 10.2, 2),
}


class LayoutTest(unittest.TestCase):
    def test_has_the_slots_of_the_flutter_base(self):
        slots = {slot.building: (slot.u, slot.v, slot.footprint) for slot in layout.SLOTS}
        self.assertEqual(len(slots), 11)
        self.assertEqual(slots, FLUTTER_SLOTS)

    def test_names_each_pad_node_after_its_building(self):
        names = {slot.building: slot.node for slot in layout.SLOTS}
        self.assertEqual(names["headquarters"], "Headquarters")
        self.assertEqual(names["coral_citadel"], "CoralCitadel")

    def test_puts_a_cell_at_its_place_on_the_plan(self):
        self.assertEqual(layout.plan(6, 6), (0, 0))
        self.assertEqual(layout.plan(12, 0), (6, 6))
        self.assertEqual(layout.plan(0, 12), (-6, -6))

    def test_runs_no_walkway_through_a_pad(self):
        for start, end in layout.WALKWAYS:
            for k in range(1, 20):
                u = start[0] + (end[0] - start[0]) * k / 20
                v = start[1] + (end[1] - start[1]) * k / 20
                inside = [s.building for s in layout.SLOTS
                          if abs(u - s.u) < s.footprint / 2 - 0.05
                          and abs(v - s.v) < s.footprint / 2 - 0.05]
                self.assertEqual(inside, [], f"walkway {start}-{end} at {u:.2f}, {v:.2f}")

    def test_reaches_every_pad_from_the_headquarters(self):
        for slot in layout.SLOTS:
            gaps = []
            for (ua, va), (ub, vb) in layout.WALKWAYS:
                for k in range(41):
                    u, v = ua + (ub - ua) * k / 40, va + (vb - va) * k / 40
                    gaps.append(max(abs(u - slot.u), abs(v - slot.v)) - slot.footprint / 2)
            self.assertLessEqual(min(gaps), layout.WALKWAY_WIDTH / 2 + 0.15, slot.building)

    def test_opens_a_gate_where_each_avenue_leaves_the_deck(self):
        self.assertEqual(len(layout.GATES), 4)
        for u, v in layout.GATES:
            self.assertTrue(u in (0, 12) or v in (0, 12))
            self.assertTrue(any((u, v) in leg for leg in layout.WALKWAYS))

    def test_keeps_the_decor_off_the_pads_walkways_and_rampart(self):
        for slot in layout.SLOTS:
            self.assertFalse(layout.free_for_decor(*layout.plan(slot.u, slot.v)))
        self.assertFalse(layout.free_for_decor(*layout.plan(6.4, 2.5 + 0.9)))
        self.assertFalse(layout.free_for_decor(*layout.plan(1.5, -0.3)))
        self.assertTrue(layout.free_for_decor(*layout.plan(0.5, 11.5)))
        self.assertTrue(layout.free_for_decor(*layout.plan(1.5, -1.2)))

    def test_measures_how_far_a_point_lies_beyond_the_deck(self):
        self.assertEqual(layout.beyond_deck(0, 0), 0)
        self.assertEqual(layout.beyond_deck(7, 0), 1)
        self.assertAlmostEqual(layout.beyond_deck(7, 7), math.sqrt(2))


if __name__ == "__main__":
    unittest.main()
