"""What the monsters' actions are made of, with no Blender: turns about any
axis, loops of sines, waves down a chain of bones, and the declaration of the
four actions every creature has (idle and swim loop, attack and hit play once).
Rotations are in degrees about the model's own axes, as workshop.rig has them."""

import math

from workshop.rig import Key

X, Y, Z = (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0)


def turn(axis, degrees):
    """The Euler angles (XYZ, degrees) of a turn of [degrees] about [axis]:
    what a Key's rotation takes, for a turn about any axis."""
    length = math.sqrt(sum(a * a for a in axis))
    x, y, z = (a / length for a in axis)
    c, s = math.cos(math.radians(degrees)), math.sin(math.radians(degrees))
    r = ((c + x * x * (1 - c), x * y * (1 - c) - z * s, x * z * (1 - c) + y * s),
         (y * x * (1 - c) + z * s, c + y * y * (1 - c), y * z * (1 - c) - x * s),
         (z * x * (1 - c) - y * s, z * y * (1 - c) + x * s, c + z * z * (1 - c)))
    angles = (math.atan2(r[2][1], r[2][2]), math.asin(max(-1.0, min(1.0, -r[2][0]))),
              math.atan2(r[1][0], r[0][0]))
    return tuple(round(math.degrees(a), 3) + 0.0 for a in angles)


def rotvec(*turns):
    """The Euler angles of several small turns made at once, each an (axis,
    degrees): their rotation vectors added, which is exact for turns about
    one axis and close for the small turns of a sway."""
    total = [0.0, 0.0, 0.0]
    for axis, degrees in turns:
        length = math.sqrt(sum(a * a for a in axis))
        total = [t + a / length * degrees for t, a in zip(total, axis)]
    size = math.sqrt(sum(t * t for t in total))
    return turn(total, size) if size > 1e-9 else (0.0, 0.0, 0.0)


def shift(axis, amount):
    """A location offset of [amount] along [axis]."""
    return tuple(round(a * amount, 4) + 0.0 for a in axis)


def cycle(frames, rotation=None, location=None, steps=8):
    """The keys of a loop of [frames] frames: [rotation](phase) and
    [location](phase) give the pose at phase 0 to 1 (None: at rest); the last
    key is the first, so it closes on itself."""
    keys = []
    for i in range(steps):
        phase = i / steps
        keys.append(Key(round(frames * phase), rotation(phase) if rotation else (0, 0, 0),
                        location(phase) if location else (0, 0, 0)))
    return keys + [Key(frames, keys[0].rotation, keys[0].location)]


def sway(frames, degrees, axis=Z, phase=0.0, steps=8):
    """A bone turning to and fro about [axis], [degrees] each way."""
    return cycle(frames, lambda p: turn(axis, degrees * math.sin(2 * math.pi * (p - phase))),
                 steps=steps)


def bob(frames, amount, axis=Z, phase=0.0, steps=8):
    """A bone moving to and fro along [axis], [amount] each way."""
    return cycle(frames, location=lambda p: shift(axis, amount * math.sin(2 * math.pi * (p - phase))),
                 steps=steps)


def wave(chain, frames, degrees, lag=0.1, axis=Z, growth=0.4):
    """A wave down [chain]: each bone sways about [axis] a little further than
    the one before ([growth]) and [lag] of a cycle behind it."""
    return {bone: sway(frames, degrees * (1 + i * growth), axis, lag * i)
            for i, bone in enumerate(chain)}


def curl(chain, degrees, axis=Z, growth=0.0):
    """The rotations that curl [chain] by [degrees] each about [axis] (more
    on each bone further down by [growth]): a pose for a key."""
    return {bone: turn(axis, degrees * (1 + i * growth)) for i, bone in enumerate(chain)}


def pose(frames_poses, tracks=None):
    """Adds to [tracks] ({bone: [Key]}) the keys of [frames_poses], a list of
    (frame, {bone: rotation or (rotation, location)}); a bone not in a pose is
    at rest there. A pose-to-pose action: anticipation, strike, recovery."""
    tracks = {} if tracks is None else tracks
    bones = {bone for _, poses in frames_poses for bone in poses}
    for bone in sorted(bones):
        keys = []
        for frame, poses in frames_poses:
            value = poses.get(bone, ((0, 0, 0), (0, 0, 0)))
            rotation, place = value if isinstance(value[0], tuple) else (value, (0, 0, 0))
            keys.append(Key(frame, rotation, place))
        tracks[bone] = keys
    return tracks


def declare(rig, idle, swim, attack, hit):
    """The four actions of a creature on [rig]: each argument is (frames,
    tracks); idle and swim loop, attack and hit play once."""
    for name, (frames, tracks), loop in (("idle", idle, True), ("swim", swim, True),
                                         ("attack", attack, False), ("hit", hit, False)):
        rig.action(name, frames, tracks, loop=loop)
