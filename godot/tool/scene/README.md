# tool/scene

Review renders of the game's startup scene, not game code, left out of
exports.

    tool/scene_capture.sh [out dir] [scene]

`capture.gd` opens `app/main.tscn` (or `scene`) in a window the size of a
phone held upright at 2x (780 x 1688, the project's 390 x 844 points), lets
it run 240 frames, then writes `default.png` (the game's view),
`rotated.png`, `close.png` (zoomed on the headquarters) and `top.png` (from
above, the quality panel open), printing each view's draw calls, primitives
and objects. Godot draws with its Compatibility renderer (the web's) under
`xvfb-run`, in software: its frame rate means nothing, its draw calls and
primitives do. The renders go to `/tmp/scene_capture/` by default: never into
the repo.

## The UI kit

`kit_capture.gd` (`tool/scene_capture.sh [out dir] kit`, or after the base's
views when no scene is given) renders the components of `presentation/ui/common`
laid out by `kit_gallery.gd` with the sample data of `kit_parts.gd`:
`kit_a.png` (pills, badge, banners, segmented bar, switches, lore), `kit_b.png`
(resource, technology, event and guide icons, portraits, the guide halo, the
tab placeholder), `kit_b_en.png` (the same page after the language changed to
English, without a rebuild), and `kit_dialog.png`, `kit_sheet.png` and
`kit_page.png` (a dialog, a bottom sheet and a full page over the first page),
each with its draw calls and primitives. Review tooling, not game code; never
commit the renders.
