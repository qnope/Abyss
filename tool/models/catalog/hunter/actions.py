"""The squid moves: it drifts with its arms trailing, jets forward with its
fins, and lashes out its two tentacles in a strike."""

import math

from catalog.hunter.arms import ARMS
from catalog.parts import motion
from catalog.parts.motion import X, Y, Z, shift, turn


def _across(k):
    """The axis arm [k] sways about: Z for the side arms, X for those above or below."""
    return Z if abs(math.cos(2 * math.pi * k / ARMS + math.pi / ARMS)) > 0.5 else X


def declare(rig, arms, tents, tip):
    """Idle (a slow drift, arms and tentacles trailing), swim (fins beating, the
    mantle pumping), attack (the tentacles coil back, then lash straight out
    as the whole body darts) and hit (flung back, arms scattering)."""
    bones = [bone for chain in arms.values() for bone in chain]
    cords = [bone for chain in tents.values() for bone in chain]
    idle = {bone: motion.sway(48, 9, _across(int(bone[3])), 0.07 * i, 4) for i, bone in enumerate(bones)}
    idle.update({bone: motion.sway(48, 7, X, 0.1 * i) for i, bone in enumerate(cords)})
    idle.update(Body=motion.bob(48, 0.03), FinR=motion.sway(48, 10, Y), FinL=motion.sway(48, 10, Y, 0.5))
    swim = {bone: motion.sway(24, 8, _across(int(bone[3])), 0.05 * i, 4) for i, bone in enumerate(bones)}
    swim.update({bone: motion.sway(24, 6, X, 0.08 * i) for i, bone in enumerate(cords)})
    swim.update(motion.wave(tip, 24, 8, 0.12))
    swim.update(Body=motion.bob(24, 0.04), FinR=motion.sway(24, 26, Y), FinL=motion.sway(24, 26, Y, 0.5))
    coil = {bone: turn(X, 38) for bone in cords}
    lash = {bone: turn(X, -12) for bone in cords}
    flare = {bone: turn(_across(int(bone[3])), 16 * (1 if int(bone[3]) % 2 else -1)) for bone in bones}
    attack = motion.pose([
        (0, {}),
        (7, {"Body": ((0, 0, 0), shift(Y, -0.15)), "Tip1": turn(Z, 12), **coil}),
        (11, {"Body": ((0, 0, 0), shift(Y, 0.6)), "Head": turn(X, -6), **lash, **flare}),
        (18, {"Body": ((0, 0, 0), shift(Y, 0.4)), **{b: turn(X, -4) for b in cords}}),
        (26, {})])
    hit = motion.pose([
        (0, {}),
        (3, {"Body": (turn(X, 14), shift(Y, -0.25)), "Head": turn(X, 10),
             **{b: turn(X, 22) for b in cords}, **flare}),
        (12, {})])
    motion.declare(rig, (48, idle), (24, swim), (26, attack), (12, hit))
