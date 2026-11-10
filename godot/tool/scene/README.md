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
