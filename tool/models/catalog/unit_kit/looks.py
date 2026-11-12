"""What a part of a unit is made of: a material, a paint and a mapping into the
units' atlas, together as a Look; and the Dress that adds parts to a model
under one group, each bound to a bone."""

from dataclasses import dataclass
from typing import Callable

from catalog import colors, paints
from workshop import noise
from workshop.colors import scale


@dataclass(frozen=True)
class Look:
    material: str
    paint: object
    uv: Callable | None


def suit(atlas, colour, seed=0):
    """Neoprene of [colour], woven, a little mottled."""
    def paint(p, normal):
        return scale(colour, 1 + 0.12 * noise.fbm(p * 6, seed, octaves=2))
    return Look("suit", paint, atlas.tiled("weave", 0.3))


def armor(atlas, colour, seed=0, tile="plate"):
    """Plates of [colour] with their rivets, edges caught by the light."""
    return Look("hull", paints.worked(colour, seed, mottle=0.1, edge=1.35), atlas.fit(tile))


def metal(atlas, colour, seed=0):
    """Rounded metal (a helmet, a tank, a ball): smooth, mottled, with no plate
    mapping. (paints.worked lights a face by its slope: on a sphere that is a
    zigzag.)"""
    def paint(p, normal):
        return scale(colour, 1 + 0.1 * noise.fbm(p * 5, seed + 5, octaves=2))
    return Look("hull", paint, atlas.solid("plain"))


def lamp(atlas, tile):
    """A light: its colour is the atlas tile [tile] (cyan, amber, red...)."""
    return Look("lamp", colors.LAMP, atlas.solid(tile))


def decal(atlas, tile, right=(1, 0, 0), up=(0, 0, 1), colour=colors.WHITE, material="hull"):
    """A badge, a visor: the whole part seen along a plane over one tile."""
    return Look(material, colour, atlas.planar(tile, right, up))


class Dress:
    """The parts of one figure, added to [model] under [group]."""

    def __init__(self, model, group="Unit"):
        self.model, self.group = model, group

    def add(self, geometry, look, bone):
        """[geometry] in [look], following [bone] (a name, or a weight function)."""
        self.model.add(self.group, geometry, look.material, look.paint, look.uv, bone=bone)

    def pair(self, make, look, bone, sides="LR"):
        """The part [make](side) of each [sides] (-1 left, 1 right), bound to
        the bone [bone] plus the side's letter."""
        for letter in sides:
            self.add(make(-1 if letter == "L" else 1), look, bone + letter)
