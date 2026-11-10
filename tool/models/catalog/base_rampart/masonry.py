"""The rampart's courses: rough blocks of coral stone laid along the ring,
each a bevelled box swollen by noise, slightly battered (narrower on top),
painted with the meanders and pores of the reef rock it was cut from."""

import math

from mathutils import Vector

from catalog import colors
from catalog.base_rampart import ring
from catalog.textures import lights, living
from workshop import noise, shapes
from workshop.atlas import Atlas, Tile
from workshop.colors import mix, scale, vary

JOINT = 0.05
# The rampart's atlas: the grain of its reef stone, which the vertex colours
# cannot hold on blocks this coarse. 512 px: one seamless tile, and white.
ATLAS = Atlas(512, 8, {"stone": Tile((0, 0, 6, 6), living.reef_stone, seamless=True),
                       "plain": Tile((6, 0, 1, 1), lights.solid((1.0, 1.0, 1.0)))})
STONE = ATLAS.tiled("stone", 0.7)


def course(model, group, bottom, height, depth, rng, shortest=0.42, longest=0.78):
    """A course of blocks from z = [bottom] to [bottom] + [height] along every
    run, [depth] thick; gives the blocks' tops as (centre, length, turn)."""
    tops = []
    for start, end in ring.runs():
        turn = math.atan2(end[1] - start[1], end[0] - start[0])
        for (x, y), length in ring.blocks(start, end, rng, shortest, longest):
            size = (length - JOINT, depth * rng.uniform(0.94, 1.04), height * rng.uniform(0.86, 1.1))
            block = stone(size, rng.randrange(1000))
            lean = (rng.uniform(-0.04, 0.04), rng.uniform(-0.03, 0.03), turn + rng.uniform(-0.03, 0.03))
            block.transform((x, y, bottom), lean)
            model.add(group, block, "reef", coral_stone(rng, rng.randrange(1000)), STONE)
            tops.append(((x, y, bottom + size[2]), length, turn))
    return tops


def stone(size, seed, batter=0.12, rough=0.04):
    """A rough block of [size] (along, across, up), standing on z = 0, open below."""
    length, depth, height = size
    block = shapes.box(size, bevel=min(0.045, height * 0.2), segments=1, bottom=False)
    block.sharp_angle = math.radians(50)

    def swell(p):
        t = max(0.0, p.z / height)
        inward = Vector((0, -p.y * batter * t, 0))
        bump = noise.vector(p * 3.1, seed) * rough
        return inward + Vector((bump.x * 0.6, bump.y, bump.z * 0.5 * t))

    return block.displace(swell)


def coral_stone(rng, seed):
    """The paint of a block: its own shade of reef rock, mottled, darker in
    its furrows, its top silted and its worn edges catching the light."""
    base = mix(colors.CORAL_STONE, colors.CORAL_STONE_PALE, rng.random())
    if rng.random() < 0.12:
        base = mix(base, colors.CORAL_STONE_ROSE, rng.uniform(0.3, 0.6))
    base = vary(base, rng, 0.1)

    def paint(p, normal):
        color = scale(base, 1 + 0.18 * noise.fbm(p * 4, seed, octaves=2))
        color = mix(color, colors.CORAL_STONE_DEEP, 0.5 * noise.cracks(p, seed, 3.0, 0.3))
        color = mix(color, colors.CORAL_STONE_DEEP, 0.4 * max(0.0, 0.2 - p.z) / 0.3)
        if normal.z > 0.8:
            return mix(color, colors.CORAL_STONE_PALE, 0.3)
        return scale(color, 1.2) if normal.z > 0.25 else color
    return paint
