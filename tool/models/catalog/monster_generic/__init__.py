"""The generic monster, for any monster that has no family of its own: the
Rôdeur of older games, whose combat key is `monsterL<level>`
(MonsterFamily.type_key_of with a null family, MonsterUnitStats.of(null, level)).
A prowling anglerfish in murky olive: a round body, an enormous underbite hung
with needle fangs, a glowing amber lure on a stalk, two stumpy walking fins.
It has no portrait: the interface shows initials for it (PortraitFiles.monster
of null is empty).

Faces +Y in Blender (Godot's forward, -Z). Origin on the floor under the middle
of the body, which hangs 0.4 above it: about 1.6 cells from its tail to the tip
of its jaw, 0.9 wide with its fins: a bit bigger than a unit. Bones: Body,
Jaw, FinR, FinL, Lure1..2 and Tail1..2."""

from catalog import monster_palette
from catalog.monster_generic import actions, body
from catalog.textures import monster
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "monster_generic"
SEED = 7707
MATERIALS = monster_palette.MONSTER
ATLAS = monster.atlas(SEED)
BUDGET = Budget(triangles=1_500, materials=4, texture_px=512, bones=8, keyframes=1_500)
OCCLUSION = Occlusion(rays=14, distance=0.4, floor=0.35, strength={"lamp": 0.0, "membrane": 0.4})
NODES = ["Rig"]
FAMILY = "monster"


def build(model):
    lure, tail = body.skeleton(model.rig)
    body.shape(model, lure, tail)
    actions.declare(model.rig, lure, tail)
