"""The floor of one cell: a grid of quads over the unit square whose heights
come from a function of (x, y), the tile's border held at one level so that
neighbours share their edges, and a skirt down to the slab under the map."""

from mathutils import Vector

from workshop.geometry import Geometry

CELLS = 12  # quads across a tile
EDGE_DROP = -0.03  # the border sits a little under the top: the grid reads
FOOT = -0.6  # the slab's thickness, as MapGrid.DEPTH


def heightfield(height, cells=CELLS):
    """The unit square as [cells] x [cells] quads, standing at z =
    [height](x, y), upward-facing, smooth. The quads run along the grid
    lines so that two tiles' borders have the same vertices."""
    geometry = Geometry(smooth=True)
    for j in range(cells + 1):
        for i in range(cells + 1):
            x, y = i / cells - 0.5, j / cells - 0.5
            geometry.verts.append(Vector((x, y, height(x, y))))
    row = cells + 1
    for j in range(cells):
        for i in range(cells):
            a = j * row + i
            geometry.faces.append((a, a + 1, a + row + 1, a + row))
    geometry.smooth = [True] * len(geometry.faces)
    return geometry


def skirt(edge_z, foot=FOOT):
    """The four sides of the slab under a tile, from its border at [edge_z]
    down to [foot]: seen where a lit neighbour stands higher than a tile
    under the fog."""
    corners = [(-0.5, -0.5), (0.5, -0.5), (0.5, 0.5), (-0.5, 0.5)]
    verts = [Vector((x, y, z)) for x, y in corners for z in (edge_z, foot)]
    return Geometry(verts, [(2 * k, 2 * k + 1, 2 * (k + 1) % 8 + 1, 2 * (k + 1) % 8)
                            for k in range(4)])


def atlas_top(atlas, name):
    """The mapping of a tile's top: the unit square spread over the atlas
    tile [name], upright, so that its borders land on the tile's borders."""
    u0, v0, u1, v1 = atlas.rect(name)

    def mapping(geometry):
        return [[(u0 + (geometry.verts[i].x + 0.5) * (u1 - u0),
                  v0 + (geometry.verts[i].y + 0.5) * (v1 - v0)) for i in face]
                for face in geometry.faces]
    return mapping
