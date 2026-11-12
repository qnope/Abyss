"""The prowler moves: its lure sways, it shuffles on its fins and lunges, jaws wide."""

from catalog.parts import motion
from catalog.parts.motion import X, Y, Z, shift, turn

FINS = ["FinR", "FinL"]


def declare(rig, lure, tail):
    """Idle (the lure swaying to draw prey), swim (fins and tail beating), attack
    (the lure dips, the body lunges and the jaw snaps) and hit (knocked back)."""
    idle = motion.wave(lure, 48, 10, 0.12, axis=X)
    idle.update({bone: motion.sway(48, 4, Z, 0.1 * i) for i, bone in enumerate(tail)})
    idle.update(Body=motion.bob(48, 0.02), Jaw=motion.sway(48, 4, X, 0.3))
    swim = motion.wave(tail, 24, 18, 0.1)
    swim.update({bone: motion.sway(24, 7, Y, 0.5 * i) for i, bone in enumerate(lure)})
    swim.update({bone: motion.sway(24, 25, Y, 0.5 * i) for i, bone in enumerate(FINS)})
    swim.update(Body=motion.sway(24, 4, Z, 0.4), Jaw=motion.sway(24, 3, X))
    attack = motion.pose([
        (0, {}),
        (5, {"Body": (turn(X, 6), shift(Y, -0.1)), "Jaw": turn(X, -40), lure[0]: turn(X, -35)}),
        (9, {"Body": ((0, 0, 0), shift(Y, 0.4)), "Jaw": turn(X, -55), lure[0]: turn(X, -50)}),
        (12, {"Body": ((0, 0, 0), shift(Y, 0.45)), "Jaw": turn(X, 6)}),
        (24, {})])
    hit = motion.pose([(0, {}), (3, {"Body": (turn(X, 20), shift(Y, -0.2)), "Jaw": turn(X, -25),
                                     lure[0]: turn(X, 30), tail[0]: turn(Z, -25)}), (12, {})])
    motion.declare(rig, (48, idle), (24, swim), (24, attack), (12, hit))
