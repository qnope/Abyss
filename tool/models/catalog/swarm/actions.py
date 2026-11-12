"""The fish of the swarm moves: a tail that wags, a jaw that snaps."""

from catalog.parts import motion
from catalog.parts.motion import X, Z, shift, turn


def declare(rig, tail):
    """Idle (a drift with a twitching jaw), swim (a quick wag), attack (draw
    back, dart forward and snap) and hit (thrown back, tail whipping)."""
    idle = motion.wave(tail, 48, 5, 0.12)
    idle["Body"] = motion.bob(48, 0.012)
    idle["Jaw"] = motion.sway(48, 5, X, 0.25)
    swim = motion.wave(tail, 24, 22, 0.1)
    swim["Body"] = motion.sway(24, 5, Z, 0.4)
    swim["Jaw"] = motion.sway(24, 4, X)
    back = {bone: turn(Z, 25) for bone in tail}
    whip = {bone: turn(Z, -22) for bone in tail}
    attack = motion.pose([
        (0, {}),
        (5, {"Body": ((0, 0, 0), shift((0, 1, 0), -0.08)), "Jaw": turn(X, -38), **back}),
        (9, {"Body": ((0, 0, 0), shift((0, 1, 0), 0.3)), "Jaw": turn(X, -55), **whip}),
        (12, {"Body": ((0, 0, 0), shift((0, 1, 0), 0.34)), "Jaw": turn(X, 6)}),
        (24, {}),
    ])
    hit = motion.pose([
        (0, {}),
        (3, {"Body": (turn(X, 25), shift((0, 1, 0), -0.18)), "Jaw": turn(X, -30),
             tail[0]: turn(Z, -30)}),
        (12, {}),
    ])
    motion.declare(rig, (48, idle), (24, swim), (24, attack), (12, hit))
