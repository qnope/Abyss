"""A Calmar-chasseur (MonsterFamily.HUNTER): a hunting squid. A long pointed
mantle in wine red with two arrow fins and rows of sulfur lights, a head with
two huge yellow slit eyes, eight short arms round a hooked mouth and two long
hunting tentacles ending in clubs of hooks. It hovers, arms forward, and
darts at the frailest.

Faces +Y in Blender (Godot's forward, -Z), the mantle behind. Origin on the
floor under the middle of the body, which hangs 0.65 above it: about 2.2 cells
from the tip of its mantle to the end of its tentacles, 1.3 wide with its fins,
0.5 high. Bones: Body, Head, Tip1..2 (the mantle's tail), FinR and FinL,
Arm0_1..Arm7_2 (eight arms of two bones) and TentR1..3, TentL1..3."""

from catalog import monster_palette
from catalog.hunter import actions, arms, body
from catalog.textures import monster
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "hunter"
SEED = 7303
MATERIALS = monster_palette.MONSTER
ATLAS = monster.atlas(SEED)
BUDGET = Budget(triangles=3_000, materials=4, texture_px=512, bones=30, keyframes=3_500)
OCCLUSION = Occlusion(rays=14, distance=0.4, floor=0.35,
                      strength={"lamp": 0.0, "membrane": 0.4})
NODES = ["Rig"]
FAMILY = "monster"
PORTRAIT = True


def build(model):
    rig = model.rig
    tip = body.skeleton(rig)
    arm_chains, tents = arms.skeleton(rig)
    body.shape(model, tip)
    arms.shape(model, arm_chains, tents)
    actions.declare(rig, arm_chains, tents, tip)
