"""The yard: the rails running out of the shaft toward the walkway, a cart
heaped with pink coral standing on them, a pile of fresh crystals, crates,
work lamps and the reef at the pad's corners."""

from catalog import colors
from catalog.coral_mine.shaft import AT, PZ
from catalog.parts import Into, belts, crystals, fittings, place, props, reef


def yard(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    place(into, belts.track(atlas, 0.5, seed=40), (AT[0] + 0.36, AT[1], PZ))
    place(into, belts.cart(atlas, rng, colors.CORAL_PINK, "pink", seed=41), (AT[0] + 0.62, AT[1], PZ + 0.035))
    place(into, crystals.cluster(atlas, rng, 6, 0.3, "pink"), (-0.42, -0.5, PZ))
    place(into, belts.chunks(atlas, rng, 6, (0.12, 0.08), colors.CORAL_PINK, "pink"), (-0.1, -0.55, PZ))
    place(into, props.crate(atlas, (0.12, 0.1, 0.1), colors.PIPE, seed=42), (0.12, -0.62, PZ), (0, 0, 0.3))
    place(into, props.drum(atlas, 0.05, 0.13, colors.CORAL_ORANGE, seed=43), (-0.7, -0.45, PZ))
    place(into, props.drum(atlas, 0.05, 0.13, colors.CORAL_ORANGE, seed=44), (-0.62, -0.58, PZ))
    place(into, fittings.beacon(atlas, 0.035, "pink", seed=45), (0.7, 0.36, PZ))
    place(into, fittings.beacon(atlas, 0.035, "amber", seed=46), (-0.72, -0.12, PZ))
    for x, y, size in ((0.76, -0.76, 0.85), (-0.77, -0.76, 0.75), (0.77, 0.75, 0.7)):
        reef.cluster(into, rng, atlas, (x, y, 0), size, 3)
