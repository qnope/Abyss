"""Le terrifiant Kraken (MonsterFamily.KRAKEN): it rises from the volcano to take
the kernel back, a boss whose tentacles strike two defenders at once. A
mountain of obsidian-violet flesh: a skirt and a tall leaning dome cracked with
molten veins and glowing embers, two huge molten eyes under horned brows, a
hooked beak, a collar of spikes, and eight arching tentacles lined with
glowing lava suckers. The two in front are the ones that strike. Its colours
are violet and bone, its light lava orange.

Faces +Y in Blender (Godot's forward, -Z). Origin on the floor under the axis of
its body, which stands on it: about 8 cells across (a radius of 4 to the
tentacle tips) and 3.7 high: it fills the base and more. Bones: Body (the
skirt, the root), Head (the dome) and T0_1..T7_4, eight tentacles of four
bones, T0 and T7 being the two in front."""

from catalog import monster_palette
from catalog.kraken import actions, body, tentacles
from catalog.textures import monster
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "kraken"
SEED = 7505
MATERIALS = monster_palette.MONSTER
ATLAS = monster.atlas(SEED)
BUDGET = Budget(triangles=7_000, materials=3, texture_px=512, bones=36, keyframes=5_500)
OCCLUSION = Occlusion(rays=14, distance=1.2, floor=0.3, strength={"lamp": 0.0, "shell": 0.6})
NODES = ["Rig"]
FAMILY = "monster"
PORTRAIT = True


def build(model):
    body.skeleton(model.rig)
    chains = tentacles.skeleton(model.rig)
    body.shape(model)
    tentacles.shape(model, chains)
    actions.declare(model.rig, chains)
