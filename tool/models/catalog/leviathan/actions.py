"""The Léviathan moves: it coils and sways, slithers, rears and slams down
with a roar, and shudders under a blow."""

from catalog.parts import motion
from catalog.parts.motion import X, Y, Z, shift, turn


def declare(rig, order):
    """Idle (a slow sway down its length, the jaw working), swim (a slither, the
    wave running from the head to the tail), attack (it rears its neck, jaw
    wide, roars, then slams its head down and snaps) and hit (reeling back,
    its tail whipping)."""
    aft = [b for b in order if b.startswith("Aft")]
    fwd = [b for b in order if b.startswith("Fwd")]
    flippers = ["FlipperR", "FlipperL"]
    idle = motion.wave(order[::-1], 48, 2.5, 0.07, growth=0.1)
    idle.update(Head=motion.sway(48, 3, X, 0.2), Jaw=motion.sway(48, 4, X, 0.4))
    idle.update({bone: motion.sway(48, 6, Y, 0.5 * i) for i, bone in enumerate(flippers)})
    swim = motion.wave(order[::-1], 36, 9, 0.1, growth=0.12)
    swim.update(Head=motion.sway(36, 6, Z, 0.9), Jaw=motion.sway(36, 3, X))
    swim.update({bone: motion.sway(36, 14, Y, 0.5 * i) for i, bone in enumerate(flippers)})
    rear = {**{b: turn(X, 13) for b in fwd}, "Head": turn(X, 12), "Jaw": turn(X, -45),
            "Body": ((0, 0, 0), shift(Y, -0.3)), **{b: turn(Z, 6) for b in aft}}
    roar = {**{b: turn(X, 15) for b in fwd}, "Head": turn(X, 18), "Jaw": turn(X, -55),
            "Body": ((0, 0, 0), shift(Y, -0.35))}
    slam = {**{b: turn(X, -18) for b in fwd}, "Head": turn(X, -20), "Jaw": turn(X, -30),
            "Body": ((0, 0, 0), shift(Y, 0.9)), **{b: turn(Z, -8) for b in aft}}
    bite = {**{b: turn(X, -22) for b in fwd}, "Head": turn(X, -22), "Jaw": turn(X, 4),
            "Body": ((0, 0, 0), shift(Y, 0.95))}
    attack = motion.pose([(0, {}), (10, rear), (16, roar), (22, slam), (26, bite), (40, {})])
    hit = motion.pose([(0, {}), (4, {"Head": turn(X, 18), "Jaw": turn(X, -30),
                                     **{b: turn(X, 5) for b in fwd},
                                     "Body": ((0, 0, 0), shift(Y, -0.4)),
                                     **{b: turn(Z, 14) for b in aft}}), (16, {})])
    motion.declare(rig, (48, idle), (36, swim), (40, attack), (16, hit))
