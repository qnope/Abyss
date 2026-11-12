"""Tests of the budgets a model must stay under."""

import unittest
from types import SimpleNamespace

from workshop.budget import Budget


def _report(triangles=100, materials=("rock",), images=(), bones=0, keyframes=0):
    return SimpleNamespace(triangles=triangles, materials=list(materials), images=list(images),
                           bones=bones, keyframes=keyframes)


class BudgetTest(unittest.TestCase):
    def test_a_model_within_its_budget_has_no_overrun(self):
        budget = Budget(triangles=100, materials=1, texture_px=0)
        self.assertEqual(budget.overruns(_report()), [])

    def test_names_each_overrun(self):
        budget = Budget(triangles=99, materials=0, texture_px=256)
        overruns = budget.overruns(_report(images=[(512, 256)]))
        self.assertEqual(overruns, [
            "100 triangles, over the budget of 99",
            "1 materials, over the budget of 0",
            "a 512 x 256 texture, over the budget of 256 px",
        ])

    def test_names_the_bones_and_keyframes_over_the_budget(self):
        budget = Budget(triangles=100, materials=1, bones=2, keyframes=10)
        self.assertEqual(budget.overruns(_report(bones=2, keyframes=10)), [])
        self.assertEqual(budget.overruns(_report(bones=3, keyframes=11)), [
            "3 bones, over the budget of 2", "11 keyframes, over the budget of 10"])

    def test_a_budget_stays_within_the_caps_of_its_family(self):
        caps = Budget(triangles=100, materials=2, texture_px=256, bones=8, keyframes=100)
        self.assertEqual(Budget(100, 2, 256, 8, 100).within(caps), [])
        self.assertEqual(Budget(101, 3, 512, 9, 101).within(caps), [
            "triangles 101, over the family's 100", "materials 3, over the family's 2",
            "texture_px 512, over the family's 256", "bones 9, over the family's 8",
            "keyframes 101, over the family's 100"])

    def test_describes_the_bones_of_a_rigged_model(self):
        budget = Budget(triangles=200, materials=4, bones=8, keyframes=100)
        self.assertEqual(budget.describe(_report(bones=6, keyframes=90)),
                         "100 / 200 triangles, 1 / 4 materials, no texture, "
                         "6 / 8 bones, 90 / 100 keyframes")

    def test_describes_the_use_of_the_budget(self):
        budget = Budget(triangles=200, materials=4, texture_px=0)
        self.assertEqual(budget.describe(_report()),
                         "100 / 200 triangles, 1 / 4 materials, no texture")


if __name__ == "__main__":
    unittest.main()
