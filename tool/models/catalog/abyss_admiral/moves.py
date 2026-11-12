"""The admiral's four actions: it stands at ease with its coat stirring, swims
upright with its tails streaming, is thrown back by a blow, and commands: the
baton raised high, then swept down to point at the foe."""

from catalog.unit_kit import actions
from catalog.unit_kit.actions import held


def declare(rig):
    actions.breathe(rig, extra=lambda ph: {"Coat1": (3 * actions.sway(ph, lag=0.2), 0, 0),
                                           "Coat2": (4 * actions.sway(ph, lag=0.35), 0, 0)},
                    depth=0.8)
    actions.swim(rig, lean=15, kick=20, arms=4,
                 extra=lambda ph: {"Coat1": (-32 + 6 * actions.sway(ph), 0, 0),
                                   "Coat2": (-22 + 10 * actions.sway(ph, lag=0.2), 0, 0)})
    actions.hit(rig, heft=0.85, extra={"Coat1": (28, 0, 0), "Coat2": (22, 0, 0)})
    wind = {"Hips": ((3, 0, 0), (0, -0.03, 0)), "Chest": (-6, 0, -10), "Head": (-8, 0, 6),
            "UpperArmR": (148, 0, 14), "ForearmR": (12, 0, 0), "HeldR": (held(62, 148, 12), 0, 0),
            "UpperArmL": (-14, 0, -12), "Coat1": (-12, 0, 0), "Coat2": (-8, 0, 0)}
    strike = {"Hips": ((-5, 0, 0), (0, 0.1, 0)), "Chest": (-8, 0, 8), "Head": (4, 0, -6),
              "UpperArmR": (72, 0, 0), "ForearmR": (8, 0, 0), "HeldR": (held(-14, 72, 8), 0, 0),
              "UpperArmL": (34, 0, 18), "ThighL": (-14, 0, 0), "ThighR": (14, 0, 0),
              "Coat1": (-34, 0, 0), "Coat2": (-24, 0, 0)}
    actions.declare(rig, "attack", 20, [(0, {}), (5, wind), (7, wind), (10, strike),
                                        (13, actions.scaled(strike, 0.92)), (20, {})])
