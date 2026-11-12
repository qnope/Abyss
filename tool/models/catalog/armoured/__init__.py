"""An Isopode cuirassé (MonsterFamily.ARMOURED): a huge armoured deep-sea
isopod, a wide dome of six overlapping plum plates banded with ochre, spiked
along its back and flanks, on seven pairs of legs, with a head shield, two
hooked mandibles and two ember eyes, two long antennae and a tail fan. Its
colours are plum and ochre, its light ember.

Faces +Y in Blender (Godot's forward, -Z). Origin on the floor under the
middle of its body, which walks on the floor: about 1.9 cells long with its
tail fan and antennae, 1.7 wide with its legs, 0.6 high. Bones: Body (the
root), Front (the head half of the roof), Head, Rear, Fan (the tail), Leg0..6
(a pair each) and the antennae AntR1..2, AntL1..2."""

from catalog import monster_palette
from catalog.armoured import actions, limbs, shell
from catalog.textures import monster
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "armoured"
SEED = 7202
MATERIALS = monster_palette.MONSTER
ATLAS = monster.atlas(SEED)
BUDGET = Budget(triangles=3_000, materials=2, texture_px=512, bones=17, keyframes=2_000)
OCCLUSION = Occlusion(rays=16, distance=0.5, floor=0.3,
                      strength={"lamp": 0.0, "shell": 0.65})
NODES = ["Rig"]
FAMILY = "monster"
PORTRAIT = True


def build(model):
    rig = model.rig
    rig.bone("Body", None, (0, 0, 0.22), (0, -0.2, 0.22))
    rig.bone("Front", "Body", (0, 0, 0.22), (0, 0.5, 0.22))
    rig.bone("Head", "Front", (0, 0.5, 0.22), (0, 0.95, 0.22))
    rig.bone("Rear", "Body", (0, 0, 0.22), (0, -0.5, 0.22))
    rig.bone("Fan", "Rear", (0, -0.5, 0.22), (0, -1.1, 0.12))
    feelers = limbs.skeleton(rig)
    shell.plates(model)
    shell.head(model)
    shell.tail(model)
    limbs.shape(model, feelers)
    actions.declare(rig, feelers)
