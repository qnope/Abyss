"""The four actions of a unit, from poses. A pose gives some bones a rotation
(degrees about the model's axes, at the bone's head) or a rotation and a
location offset: {"Chest": (-4, 0, 0), "Hips": ((0, 0, 0), (0, -0.1, 0))}. An
action is a list of (frame, pose): a bone a pose leaves out is at rest there.
The units share idle, swim and hit (their style says how hard); each has its
own attack.

Positive X turns a hanging limb forward (+Y) and a standing body back; Z turns
the figure to its left; Y leans it to its right."""

import math

from workshop.rig import Key

REST = (0.0, 0.0, 0.0)


def _split(value):
    """The (rotation, location) of a pose's value for a bone."""
    if value and isinstance(value[0], (tuple, list)):
        return tuple(value[0]), tuple(value[1])
    return tuple(value), REST


def merged(*poses):
    """The poses laid one over the other: rotations and locations add up."""
    total = {}
    for pose in poses:
        for bone, value in pose.items():
            rotation, location = _split(value)
            old_r, old_l = total.get(bone, (REST, REST))
            total[bone] = (tuple(a + b for a, b in zip(old_r, rotation)),
                           tuple(a + b for a, b in zip(old_l, location)))
    return total


def scaled(pose, factor):
    """[pose] [factor] times as far from rest."""
    return {bone: (tuple(a * factor for a in r), tuple(a * factor for a in loc))
            for bone, (r, loc) in ((b, _split(v)) for b, v in pose.items())}


def held(net, *turns):
    """The turn of a held tool's own bone that makes it [net] degrees about X
    in all, once the [turns] of the arm and forearm it is carried by are
    counted: a tool's aim is what a pose means, not the sum of its joints."""
    return net - sum(turns)


def declare(rig, name, frames, steps, loop=False):
    """Adds the action [name] of [frames] frames: every bone any step poses
    gets a key at each step, rounded for the glb."""
    bones = sorted({bone for _, pose in steps for bone in pose})
    tracks = {}
    for bone in bones:
        keys = []
        for frame, pose in steps:
            rotation, location = _split(pose.get(bone, REST))
            keys.append(Key(frame, tuple(round(a, 3) for a in rotation),
                            tuple(round(a, 4) for a in location)))
        tracks[bone] = keys
    rig.action(name, frames, tracks, loop=loop)


def cycle(frames, steps, pose_at):
    """[steps] evenly spaced poses of a loop: [pose_at](phase) for phase 0 to 1,
    where 1 is the same pose as 0."""
    return [(round(frames * k / steps), pose_at(k / steps)) for k in range(steps + 1)]


def sway(phase, turns=1, lag=0.0):
    """sin of [turns] turns of the phase, [lag] of a turn behind."""
    return math.sin(2 * math.pi * turns * (phase - lag))


def breathe(rig, extra=None, depth=1.0):
    """A slow idle of 2 seconds: the chest rises and falls, the head and arms
    follow a little, the body bobs. [extra](phase) adds a unit's own motion."""
    def pose(phase):
        s, lag = sway(phase), sway(phase, lag=0.12)
        base = {"Hips": (REST, (0, 0, 0.012 * depth * s)),
                "Chest": (-2.0 * depth * s, 0, 0), "Head": (1.5 * depth * lag, 0, 0.8 * depth * s),
                "UpperArmL": (2.5 * depth * lag, 0, -1.5 * depth * s),
                "UpperArmR": (2.5 * depth * lag, 0, 1.5 * depth * s)}
        return merged(base, extra(phase) if extra else {})
    declare(rig, "idle", 48, cycle(48, 4, pose), loop=True)


def swim(rig, lean=24.0, kick=30.0, arms=10.0, extra=None):
    """A flutter kick in one second: the body leans [lean] degrees into the
    water and rises off the floor, the legs beat [kick] degrees, the arms
    sweep [arms]; [extra](phase) adds a unit's own motion (a cape trailing)."""
    def pose(phase):
        s, c = sway(phase), sway(phase, lag=-0.25)
        legs = {"ThighL": (kick * s, 0, 0), "ThighR": (-kick * s, 0, 0),
                "ShinL": (-12 - 14 * sway(phase, lag=0.18), 0, 0),
                "ShinR": (-12 + 14 * sway(phase, lag=0.18), 0, 0)}
        body = {"Hips": ((-lean, 0, 0), (0, 0, 0.2 + 0.03 * sway(phase, 2))),
                "Chest": (lean * 0.4 + 2 * c, 3 * s, 0), "Head": (lean * 0.45, 0, -2 * s),
                "UpperArmL": (arms * c - 8, 0, 0), "UpperArmR": (-arms * c - 8, 0, 0)}
        return merged(legs, body, extra(phase) if extra else {})
    declare(rig, "swim", 24, cycle(24, 8, pose), loop=True)


def hit(rig, heft=1.0, extra=None):
    """A recoil of half a second: the figure is thrown back, its head snaps
    after it, and it recovers. [heft] below 1 is a heavy unit that gives little
    ground; [extra] is a unit's own pose at the blow."""
    blow = merged({"Hips": ((14, 0, 4), (0, -0.14, 0.02)), "Chest": (10, 0, -4),
                   "Head": (22, 0, 8), "UpperArmL": (-22, 0, -10), "UpperArmR": (-18, 0, 12),
                   "ThighL": (-10, 0, 0), "ThighR": (8, 0, 0)}, extra or {})
    steps = [(0, {}), (3, scaled(blow, heft)), (7, scaled(blow, heft * 0.35)), (12, {})]
    declare(rig, "hit", 12, steps)
