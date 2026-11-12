"""A Requin dormeur (MonsterFamily.COLOSSUS): a giant sleeping shark, a boss. A
mountain of violet-slate hide with a bone-pale belly, lying on the sea floor
with its pectoral fins splayed, barnacles and reef growing on its back, a blunt
head with an underslung mouth of two rows of teeth, and two blood-red eyes
under heavy lids that open when it wakes; five glowing gill slits each side.
Its idle is a slow breathing.

Faces +Y in Blender (Godot's forward, -Z). Origin on the floor under the middle
of the trunk, which rests on it: about 4.5 cells long with its tail fin, 2.8
wide with its pectoral fins, 1.7 high at the dorsal fin. Bones: Body (the root),
Head, Jaw, LidR, LidL, PecR, PecL and Tail1..3."""

from catalog import monster_palette
from catalog.colossus import actions, body, head
from catalog.textures import monster
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "colossus"
SEED = 7404
MATERIALS = monster_palette.MONSTER
ATLAS = monster.atlas(SEED)
BUDGET = Budget(triangles=5_000, materials=3, texture_px=512, bones=10, keyframes=2_000)
OCCLUSION = Occlusion(rays=16, distance=0.9, floor=0.3, strength={"lamp": 0.0, "shell": 0.6})
NODES = ["Rig"]
FAMILY = "monster"
PORTRAIT = True


def build(model):
    tail = body.skeleton(model.rig)
    body.shape(model, tail)
    head.shape(model)
    actions.declare(model.rig, tail)
