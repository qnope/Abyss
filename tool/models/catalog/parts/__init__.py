"""Parts the colony's buildings share: hatches and portholes, pipes, rails,
lamps and the reef that grows on them. A maker gives its parts as
(geometry, material, paint, uv) in its own frame, the UVs already mapped
into the building's atlas, so that they hold once the part is turned into
place: place() turns them and adds them to a group or a piece."""

from catalog import colors


def place(target, parts, location=(0, 0, 0), rotation=(0, 0, 0), scale=1.0):
    """Turns each part into place, then adds it to [target]: a MeshBuilder
    (a piece) or Into(model, group)."""
    for geometry, material, paint, uv in parts:
        geometry.transform(location, rotation, scale)
        target.add(geometry, material, paint, uv)


class Into:
    """The static group [group] of [model], taking parts as a piece does."""

    def __init__(self, model, group):
        self.model, self.group = model, group

    def add(self, geometry, material, paint, uv=None):
        self.model.add(self.group, geometry, material, paint, uv)


# Decor (catalog/decor) made for the colony's textured materials: its coral
# takes the reef's pores, its glow a lamp's colour.
_LIGHTS = {"glow": "cyan", "glow_pink": "pink"}


def dress(decor, atlas, period=0.35):
    """The (geometry, material, paint) of a decor maker as parts."""
    parts = []
    for geometry, material, paint in decor:
        if material in _LIGHTS:
            parts.append((geometry, "lamp", colors.LAMP, atlas.solid(_LIGHTS[material])(geometry)))
        elif material in ("coral", "rock"):
            parts.append((geometry, "reef", paint, atlas.tiled("coral", period)(geometry)))
        else:
            parts.append((geometry, material, paint, None))
    return parts


def sides_and_top(atlas, geometry, side, top):
    """A mapping of a block: its sides fitted with [side], its top with [top]."""
    sides, tops = atlas.fit(side)(geometry), atlas.fit(top)(geometry)
    return [tops[i] if geometry.face_normal(i).z > 0.9 else sides[i]
            for i in range(len(geometry.faces))]


def light(atlas, tile):
    """A lamp's paint and mapping: dim, so the tile's light is its colour."""
    return "lamp", colors.LAMP, atlas.solid(tile)
