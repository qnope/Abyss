"""The sleeping shark moves: it breathes, it swims slowly, and it wakes to
bite, its lids opening on red eyes."""

from catalog.parts import motion
from catalog.parts.motion import X, Y, Z, shift, turn

LIDS = ["LidR", "LidL"]
PECS = ["PecR", "PecL"]


def declare(rig, tail):
    """Idle (a slow breathing: the chest rises, the jaw parts a little), swim
    (a heavy beat of the tail), attack (the lids open, the head rears with
    the jaw wide, then the body lunges and the jaw snaps shut) and hit
    (flinching, the tail lashing, the eyes flaring open)."""
    idle = motion.wave(tail, 48, 2.5, 0.12)
    idle.update(Body=motion.bob(48, 0.025), Head=motion.sway(48, 1.2, X, 0.1),
                Jaw=motion.sway(48, 3, X, 0.25))
    idle.update({bone: motion.sway(48, 3, Y, 0.1 * i) for i, bone in enumerate(PECS)})
    swim = motion.wave(tail, 36, 13, 0.15, growth=0.5)
    swim.update(Body=motion.sway(36, 3, Z, 0.2), Head=motion.sway(36, 4, Z, 0.35))
    swim.update({bone: motion.sway(36, 12, Y, 0.5 * i) for i, bone in enumerate(PECS)})
    wide = {bone: turn(X, 60) for bone in LIDS}
    attack = motion.pose([
        (0, {}),
        (5, {**wide, "Head": turn(X, 6)}),
        (11, {**wide, "Head": turn(X, 20), "Jaw": turn(X, -38), "Body": (turn(X, 4), shift(Y, -0.1)),
              **{bone: turn(Z, 14) for bone in tail}}),
        (17, {**wide, "Head": turn(X, -6), "Jaw": turn(X, -6), "Body": ((0, 0, 0), shift(Y, 0.7)),
              **{bone: turn(Z, -12) for bone in tail}}),
        (21, {**wide, "Jaw": turn(X, 4), "Body": ((0, 0, 0), shift(Y, 0.75))}),
        (34, {})])
    hit = motion.pose([
        (0, {}),
        (4, {**wide, "Body": (turn(Z, 4), shift(Y, -0.2)), "Head": turn(Z, 12),
             **{bone: turn(Z, -20) for bone in tail}}),
        (14, {})])
    motion.declare(rig, (48, idle), (36, swim), (34, attack), (14, hit))
