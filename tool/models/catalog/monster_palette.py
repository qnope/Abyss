"""The materials and colours of the monsters. The colony's units are metal with
warm and cyan lights; the monsters are organic: sickly deep-sea tones (bruised
greens, plums, wine, slate, ink) with one hostile light each (acid, sulfur,
ember, blood, lava), which the lamp material takes from the atlas.

Four materials, so four draw calls: flesh (soft skin and hide), shell (chitin,
teeth, bone, claws), membrane (thin fins and webs, seen from both sides) and
the lamp that every eye and photophore shares."""

from catalog.palette import LAMP
from workshop.colors import linear
from workshop.materials import Material

FLESH = Material("flesh", roughness=0.6, textured=True)
SHELL = Material("shell", roughness=0.38, metallic=0.1, textured=True)
MEMBRANE = Material("membrane", roughness=0.55, double_sided=True, textured=True)

MONSTER = [FLESH, SHELL, MEMBRANE, LAMP]

# Bone, tooth and glass: the pale, cold things in a monster's mouth.
BONE = linear("#d9d2b4")
GLASS_TOOTH = linear("#d6f0d8")
# The shadow of a mouth, a gill, a crevice.
MAW = linear("#2a0f18")
