"""The saboteur's four actions: it crouches low and still, swims fast and flat
like an eel, is thrown back by any blow (it is glass), and strikes by
unclipping its limpet mine, reaching out and pressing it onto the target."""

from catalog.unit_kit import actions


def declare(rig):
    actions.breathe(rig, extra=lambda ph: {"Chest": (3 * actions.sway(ph, lag=0.1), 0, 0)}, depth=1.1)
    actions.swim(rig, lean=40, kick=34, arms=5,
                 extra=lambda ph: {"Head": (-14, 0, 0), "UpperArmL": (-20, 0, 0),
                                   "Mine": (0, 0, 0)})
    actions.hit(rig, heft=1.4, extra={"Mine": (20, 0, 0)})
    crouch = {"Hips": ((-16, 0, 0), (0, 0.02, -0.05)), "Chest": (-8, 0, 0),
              "ThighL": (30, 0, 0), "ThighR": (30, 0, 0), "ShinL": (-40, 0, 0), "ShinR": (-40, 0, 0)}
    wind = actions.merged(crouch, {"UpperArmL": (46, 0, 8), "ForearmL": (-30, 0, 0),
                                   "Chest": (0, 0, -10),
                                   "Mine": ((0, 0, 0), (0.07, 0.09, 0.0)), "UpperArmR": (-34, 0, 0)})
    strike = actions.merged(crouch, {"Hips": ((0, 0, 0), (0, 0.22, -0.02)),
                                     "UpperArmL": (74, 0, -4), "ForearmL": (16, 0, 0),
                                     "Mine": ((0, 0, 0), (0.15, 0.4, -0.13)),
                                     "UpperArmR": (-40, 0, 0), "Head": (-10, 0, 0)})
    actions.declare(rig, "attack", 20, [(0, {}), (4, crouch), (6, wind), (9, strike),
                                        (13, strike), (20, {})])
