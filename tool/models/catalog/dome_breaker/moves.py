"""The dome breaker's four actions: it stands heavy with the hammer on its
shoulder, wades with it, shrugs off a blow, and strikes by swinging the hammer
up over its head and bringing it down in front of it with its whole weight."""

from catalog.unit_kit import actions
from catalog.unit_kit.actions import held


def declare(rig):
    actions.breathe(rig, extra=lambda ph: {"HeldR": (1.5 * actions.sway(ph, lag=0.2), 0, 0)}, depth=0.9)
    actions.swim(rig, lean=16, kick=18, arms=3,
                 extra=lambda ph: {"UpperArmR": (6, 0, 0), "HeldR": (held(-30, 6), 0, 0)})
    actions.hit(rig, heft=0.55, extra={"HeldR": (-14, 0, 0)})
    wind = {"Hips": ((8, 0, 0), (0, -0.06, 0.0)), "Chest": (10, 0, 0),
            "UpperArmR": (158, 0, 0), "ForearmR": (10, 0, 0), "HeldR": (held(24, 158, 10), 0, 0),
            "UpperArmL": (-30, 0, 0), "ThighL": (10, 0, 0), "ThighR": (-10, 0, 0), "Head": (-8, 0, 0)}
    strike = {"Hips": ((-24, 0, 0), (0, 0.2, -0.05)), "Chest": (-14, 0, 0),
              "UpperArmR": (52, 0, 0), "ForearmR": (22, 0, 0), "HeldR": (held(-128, 52, 22), 0, 0),
              "UpperArmL": (44, 0, 0), "ThighL": (-26, 0, 0), "ThighR": (22, 0, 0),
              "ShinR": (-20, 0, 0), "Head": (-6, 0, 0)}
    actions.declare(rig, "attack", 22, [(0, {}), (5, wind), (7, wind), (10, strike),
                                        (14, actions.scaled(strike, 0.95)), (22, {})])
