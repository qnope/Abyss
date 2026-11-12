"""What the ambient creatures of the map share: their loops (a bone swinging
about an axis, a body bobbing) and their lengths. The creatures swim over the
map for life, harmless and small; they have the two loops every moving model
has, idle and swim, and nothing else: they neither attack nor are hit."""

import math

from workshop.rig import Key

SAMPLES = 8  # keys round a loop, the first repeated at its end


def swing(frames, rotation=(0.0, 0.0, 0.0), location=(0.0, 0.0, 0.0), phase=0.0):
    """The keys of a loop of [frames] frames in which a bone turns by
    [rotation] degrees about each axis and moves by [location], each as a sine
    wave [phase] (a share of the loop) late. It ends where it starts."""
    keys = []
    for k in range(SAMPLES):
        wave = math.sin(2 * math.pi * (k / SAMPLES - phase))
        keys.append(Key(round(frames * k / SAMPLES),
                        tuple(round(r * wave, 4) for r in rotation),
                        tuple(round(m * wave, 5) for m in location)))
    return keys + [Key(frames, keys[0].rotation, keys[0].location)]


def chain_swing(bones, frames, rotation, lag, grow=1.4, tracks=None, location=(0, 0, 0)):
    """Adds to [tracks] a wave running along [bones]: each swings [grow] times
    more than the one before it, [lag] of the loop later."""
    tracks = {} if tracks is None else tracks
    for i, bone in enumerate(bones):
        turn = tuple(r * grow ** i for r in rotation)
        tracks[bone] = swing(frames, turn, location if i == 0 else (0, 0, 0), lag * i)
    return tracks
