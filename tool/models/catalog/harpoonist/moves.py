"""The harpooner's four actions: it keeps its harpoon cocked, swims with it
levelled ahead, and strikes by twisting its chest back and driving the
harpoon forward in a lunge."""

from catalog.unit_kit import actions
from catalog.unit_kit.actions import held


def declare(rig):
    actions.breathe(rig, extra=lambda ph: {"HeldR": (2.0 * actions.sway(ph, lag=0.2), 0, 0)})
    actions.swim(rig, lean=26, kick=26, arms=5,
                 extra=lambda ph: {"UpperArmR": (20, 0, 0), "HeldR": (held(-60, 20), 0, 0)})
    actions.hit(rig, heft=0.9, extra={"HeldR": (-18, 0, 0), "UpperArmR": (14, 0, 0)})
    wind = {"Hips": ((4, 0, 0), (0, -0.05, 0)), "Chest": (4, 0, -30), "Head": (0, 0, 14),
            "UpperArmR": (-55, 0, 0), "ForearmR": (-14, 0, 0), "HeldR": (held(14, -55, -14), 0, 0),
            "UpperArmL": (28, 0, 0), "ThighL": (10, 0, 0), "ThighR": (-14, 0, 0)}
    strike = {"Hips": ((-6, 0, 0), (0, 0.2, 0.0)), "Chest": (-6, 0, 26), "Head": (0, 0, -12),
              "UpperArmR": (52, 0, -6), "ForearmR": (-8, 0, 0),
              "HeldR": ((held(-88, 52, -8), 0, 0), (0, 0.1, 0)), "UpperArmL": (-24, 0, -8),
              "ThighL": (-24, 0, 0), "ThighR": (22, 0, 0), "ShinR": (-24, 0, 0)}
    actions.declare(rig, "attack", 20, [(0, {}), (4, wind), (6, wind), (9, strike),
                                        (12, actions.scaled(strike, 0.9)), (20, {})])
