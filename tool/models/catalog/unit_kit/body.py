"""The skeleton the six units share: a diver in the colony's armour, one build
each (its proportions, the bend of its arms), the same 14 bones. Pure Python,
no Blender: parts and actions read their joints from the Build.

The figure faces +Y (Godot's forward, -Z), its right hand is +X, and it stands
with its feet on z = 0. Bone names: Hips (the root), Chest, Head, UpperArm /
Forearm / Held and Thigh / Shin on each side (L = -X, R = +X), and Pack on the
back; a unit adds its own (a cape, a hose) under these."""

import math
from dataclasses import dataclass

SIDES = {"L": -1, "R": 1}


@dataclass(frozen=True)
class Build:
    """The proportions of a figure, in metres. [leg] runs from the floor to the
    hip, [torso] from the hip to the neck, [head] is the helmet's radius.
    The arms hang from the shoulders [splay] degrees out and [swing] forward,
    their forearms [bend] more forward: the stance the model rests in. A [stoop]
    carries the head that far forward."""

    leg: float = 0.3
    torso: float = 0.3
    head: float = 0.2
    shoulder: float = 0.2
    hip: float = 0.09
    upper: float = 0.15
    fore: float = 0.15
    splay: float = 14.0
    swing: float = 8.0
    bend: float = 40.0
    stoop: float = 0.0

    @property
    def neck(self):
        return self.leg + self.torso

    @property
    def top(self):
        return self.neck + 2 * self.head

    def hip_joint(self, side):
        return (side * self.hip, 0.0, self.leg)

    def knee(self, side):
        return (side * self.hip, 0.01, self.leg * 0.5)

    def ankle(self, side):
        return (side * self.hip, 0.0, 0.05)

    def shoulder_joint(self, side):
        return (side * self.shoulder, 0.0, self.neck - 0.04)

    def elbow(self, side):
        return _step(self.shoulder_joint(side), self.upper, side, self.splay, self.swing)

    def wrist(self, side):
        return _step(self.elbow(side), self.fore, side, self.splay * 0.5, self.swing + self.bend)

    def head_centre(self):
        return (0.0, self.stoop, self.neck + self.head * 0.9)


def _step(origin, length, side, splay, swing):
    """The point [length] from [origin] along a limb hanging [splay] degrees
    out and [swing] degrees forward."""
    out, fwd = math.radians(splay), math.radians(swing)
    return (origin[0] + side * length * math.sin(out) * math.cos(fwd),
            origin[1] + length * math.sin(fwd),
            origin[2] - length * math.cos(out) * math.cos(fwd))


def humanoid(rig, build):
    """Declares the 14 bones of [build] on [rig]; the bone names of every unit."""
    b = build
    rig.bone("Hips", None, (0, 0, b.leg), (0, 0, b.leg + 0.08))
    rig.bone("Chest", "Hips", (0, 0, b.leg + 0.05), (0, 0, b.neck))
    rig.bone("Head", "Chest", (0, 0, b.neck), (0, 0, b.top))
    rig.bone("Pack", "Chest", (0, -0.1, b.leg + b.torso * 0.5), (0, -0.2, b.leg + b.torso * 0.5))
    for letter, side in SIDES.items():
        rig.bone("Thigh" + letter, "Hips", b.hip_joint(side), b.knee(side))
        rig.bone("Shin" + letter, "Thigh" + letter, b.knee(side), b.ankle(side))
        rig.bone("UpperArm" + letter, "Chest", b.shoulder_joint(side), b.elbow(side))
        rig.bone("Forearm" + letter, "UpperArm" + letter, b.elbow(side), b.wrist(side))
        wrist = b.wrist(side)
        rig.bone("Held" + letter, "Forearm" + letter, wrist, (wrist[0], wrist[1], wrist[2] - 0.1))
