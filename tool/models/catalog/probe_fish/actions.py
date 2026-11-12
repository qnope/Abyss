"""The probe fish's four actions: idle and swim loop, attack and hit play
once and give back to idle."""

import math

from workshop.rig import Key


def wave(chain, frames, degrees, lag):
    """A tail that undulates once over [frames]: each bone of [chain] turns
    about Z, further than the one before, [lag] frames behind it. It ends
    where it starts."""
    tracks = {}
    for i, bone in enumerate(chain):
        amplitude = degrees * (1 + i * 0.4)

        def turn(t, amplitude=amplitude, i=i):
            return Key(t, (0, 0, round(amplitude * math.sin(2 * math.pi * (t - i * lag) / frames), 3)))

        keys = [turn(frames * k // 4) for k in range(4)]
        tracks[bone] = keys + [Key(frames, keys[0].rotation)]
    return tracks


def declare(rig, chain):
    """Adds idle, swim, attack and hit to [rig], whose tail is [chain]."""
    idle = wave(chain, 48, 6, 6)
    idle["Body"] = [Key(0), Key(24, location=(0, 0, 0.04)), Key(48)]
    rig.action("idle", 48, idle, loop=True)
    rig.action("swim", 24, wave(chain, 24, 22, 3), loop=True)
    lunge = wave(chain, 24, 30, 2)
    lunge["Body"] = [Key(0), Key(6, location=(0, -0.12, 0)), Key(10, location=(0, 0.5, 0)),
                     Key(24)]
    rig.action("attack", 24, lunge)
    rig.action("hit", 12, {"Body": [Key(0), Key(3, (25, 0, 10), (0, -0.2, 0)), Key(12)],
                           chain[0]: [Key(0), Key(3, (0, 0, -30)), Key(12)]})
