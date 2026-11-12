"""The scout's four actions: it darts, so it swims low and fast, its antenna
and fins streaming; it strikes by lunging in with its prod."""

from catalog.unit_kit import actions


def declare(rig):
    actions.breathe(rig, extra=lambda ph: {"Pack": (0, 0, 2.5 * actions.sway(ph, lag=0.3))}, depth=1.3)
    actions.swim(rig, lean=36, kick=36, arms=6,
                 extra=lambda ph: {"Head": (-4, 0, 0), "Pack": (-14 + 4 * actions.sway(ph), 0, 0)})
    actions.hit(rig, heft=1.35, extra={"Pack": (30, 0, 0)})
    wind = {"Hips": ((6, 0, -14), (0, -0.07, 0)), "Chest": (6, 0, 16), "UpperArmR": (-40, 0, 6),
            "ForearmR": (-30, 0, 0), "Pack": (12, 0, 0)}
    strike = {"Hips": ((-16, 0, 12), (0, 0.34, 0.02)), "Chest": (-8, 0, -14),
              "UpperArmR": (88, 0, -4), "ForearmR": (-12, 0, 0), "UpperArmL": (-30, 0, -12),
              "ThighL": (24, 0, 0), "ThighR": (-26, 0, 0), "ShinL": (-12, 0, 0),
              "ShinR": (-28, 0, 0), "Pack": (-24, 0, 0)}
    actions.declare(rig, "attack", 18, [(0, {}), (4, wind), (8, strike),
                                        (11, actions.scaled(strike, 0.9)), (18, {})])
