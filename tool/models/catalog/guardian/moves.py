"""The guardian's four actions: it stands square behind its shield, wades
slowly, gives little ground when hit, and strikes by drawing the shield back
and slamming it forward with its whole weight."""

from catalog.unit_kit import actions
from catalog.unit_kit.actions import held


def declare(rig):
    actions.breathe(rig, extra=lambda ph: {"HeldL": (1.5 * actions.sway(ph, lag=0.25), 0, 0)}, depth=0.8)
    actions.swim(rig, lean=16, kick=20, arms=4,
                 extra=lambda ph: {"UpperArmL": (10, 0, 0), "UpperArmR": (6, 0, 0)})
    actions.hit(rig, heft=0.55, extra={"UpperArmL": (-16, 0, 0), "HeldL": (6, 0, 0)})
    wind = {"Hips": ((6, 0, 0), (0, -0.07, -0.02)), "Chest": (6, 0, 24),
            "UpperArmL": (-38, 0, 8), "ForearmL": (-12, 0, 0), "HeldL": (held(10, -38, -12), 0, 0),
            "UpperArmR": (-24, 0, 0),
            "ThighL": (14, 0, 0), "ThighR": (-14, 0, 0), "Head": (0, 0, -10)}
    strike = {"Hips": ((-8, 0, 0), (0, 0.27, -0.01)), "Chest": (-6, 0, -22),
              "UpperArmL": (60, 0, -4), "ForearmL": (6, 0, 0), "HeldL": ((held(-8, 60, 6), 0, 0), (0, 0.1, 0)),
              "UpperArmR": (30, 0, 0), "ThighL": (-24, 0, 0), "ThighR": (24, 0, 0),
              "ShinR": (-18, 0, 0), "Head": (0, 0, 8)}
    actions.declare(rig, "attack", 20, [(0, {}), (4, wind), (6, wind), (9, strike),
                                        (12, actions.scaled(strike, 0.9)), (20, {})])
