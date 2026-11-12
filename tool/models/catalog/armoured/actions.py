"""The isopod moves: it crawls on its alternating legs, and rears to slam."""

from catalog.armoured import limbs
from catalog.parts import motion
from catalog.parts.motion import X, Y, Z, shift, turn


def declare(rig, feelers):
    """Idle (it breathes, its antennae feel the water), swim (it crawls, the
    legs beating in turn), attack (it rears up on its rear plates and slams
    its head down) and hit (it hunches under the blow)."""
    ants = [bone for chain in feelers.values() for bone in chain]
    legs = [f"Leg{i}" for i in range(len(limbs.LEG_Y))]
    idle = {bone: motion.sway(72, 9, Z, 0.15 * (i % 2)) for i, bone in enumerate(ants)}
    idle["Front"] = motion.sway(72, 1.5, X)
    idle["Fan"] = motion.sway(72, 5, Z, 0.3)
    swim = {bone: motion.sway(24, 14, Z, 0.5 * (i % 2)) for i, bone in enumerate(legs)}
    swim["Body"] = motion.sway(24, 2.5, Y)
    swim["Head"] = motion.sway(24, 4, Z, 0.25)
    for i, bone in enumerate(ants):
        swim[bone] = motion.sway(24, 12, Z, 0.1 * i)
    reared = {"Body": ((0, 0, 0), shift(Y, -0.1)), "Front": turn(X, 28), "Head": turn(X, 14),
              **{bone: turn(Z, 18 * (-1) ** i) for i, bone in enumerate(legs[:3])}}
    slam = {"Body": ((0, 0, 0), shift(Y, 0.3)), "Front": turn(X, -8), "Head": turn(X, -10),
            "Fan": turn(X, 14)}
    attack = motion.pose([(0, {}), (8, reared), (14, slam),
                          (22, {"Body": ((0, 0, 0), shift(Y, 0.12)), "Front": turn(X, 3)}), (30, {})])
    hit = motion.pose([(0, {}), (4, {"Body": (turn(X, 5), shift(Z, -0.05)), "Front": turn(X, -7),
                                     "Head": turn(X, 8)}), (14, {})])
    motion.declare(rig, (72, idle), (24, swim), (30, attack), (14, hit))
