"""Tests of the budgets a model must stay under."""

import unittest
from types import SimpleNamespace

from workshop.budget import Budget


def _report(triangles=100, materials=("rock",), images=()):
    return SimpleNamespace(triangles=triangles, materials=list(materials), images=list(images))


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

    def test_describes_the_use_of_the_budget(self):
        budget = Budget(triangles=200, materials=4, texture_px=0)
        self.assertEqual(budget.describe(_report()),
                         "100 / 200 triangles, 1 / 4 materials, no texture")


if __name__ == "__main__":
    unittest.main()
