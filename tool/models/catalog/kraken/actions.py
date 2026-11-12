"""The Kraken moves: its tentacles writhe, ripple as it swims, and the two in
front rise high and slam down together."""

import math

from catalog.kraken.tentacles import COUNT, FRONT, lift_axis
from catalog.parts import motion
from catalog.parts.motion import X, Y, Z, rotvec, shift, turn
from workshop.rig import Key


def _writhe(chains, frames, lift, side, lag, steps=6):
    """Every tentacle's bones swaying: a [lift] up and down in their own
    plane and a [side] to and fro, each [lag] of a cycle behind the one before
    it and each tentacle out of step with its neighbour."""
    tracks = {}
    for k, chain in chains.items():
        up = lift_axis(k)
        for i, bone in enumerate(chain):
            shift_ = (k * 0.17 + i * lag) % 1.0
            tracks[bone] = motion.cycle(frames, lambda p, up=up, s=shift_, i=i: rotvec(
                (up, lift * (1 + 0.3 * i) * math.sin(2 * math.pi * (p - s))),
                (Z, side * (1 + 0.3 * i) * math.sin(2 * math.pi * (p - s - 0.25)))), steps=steps)
    return tracks


def _bend(chains, ks, degrees, grow=1.0):
    """A pose that bends the tentacles [ks] by [degrees] a bone about their own
    lift axis (negative lifts them)."""
    return {bone: turn(lift_axis(k), degrees * grow ** i) for k in ks for i, bone in enumerate(chains[k])}


def declare(rig, chains):
    """Idle (a slow writhing), swim (a ripple that runs out each tentacle), attack
    (the two front tentacles curl up and back over the head, then slam down
    together while the rest brace) and hit (flung back, tentacles flaring)."""
    idle = _writhe(chains, 36, 5, 4, 0.12)
    idle.update(Head=motion.sway(36, 2, X, 0.2), Body=motion.bob(36, 0.04))
    swim = _writhe(chains, 24, 12, 3, 0.18, steps=4)
    swim.update(Body=motion.bob(24, 0.08), Head=motion.sway(24, 3, X, 0.3))
    others = [k for k in range(COUNT) if k not in FRONT]
    wind = {**_bend(chains, FRONT, -30), "Head": turn(X, 14), "Body": ((0, 0, 0), shift(Y, -0.15))}
    slam = {**_bend(chains, FRONT, 34), **_bend(chains, others, 8), "Head": turn(X, -14),
            "Body": ((0, 0, 0), shift(Y, 0.35))}
    hold = {**_bend(chains, FRONT, 12), "Head": turn(X, -6), "Body": ((0, 0, 0), shift(Y, 0.25))}
    attack = motion.pose([(0, {}), (9, wind), (14, slam), (20, hold), (28, {})])
    flare = {**_bend(chains, range(COUNT), -14), "Head": turn(X, 12), "Body": ((0, 0, 0), shift(Y, -0.25))}
    hit = motion.pose([(0, {}), (4, flare), (14, {})])
    motion.declare(rig, (36, idle), (24, swim), (28, attack), (14, hit))
