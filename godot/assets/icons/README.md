# assets/icons

The interface's icons, copied from the Flutter assets (`assets/icons/`):
`resources/` (the 5 resources, named as `ResourceType`), `tech/` (the 21
technologies), `events/` (7), `factions/` (10), `guide/` (the tutorial's
guide). The owner validated that interface icons keep their SVG; the world's
buildings, units, monsters, terrain and decor are never copied here, they
come from the 3D models (`presentation/ui/common/portrait.gd` stands in for
them until step 7). `ui/` holds the glyphs the components need
(`chevron_right`, `warning`, `info`, `arrow_back`, `add`, `remove`, `check`,
`person`, `settings`, `more_vert`, `delete_outline`, and the game screen's `home`,
`map`, `shield`, `science` and `skip_next`, and the base's `lock`,
`arrow_upward`, `graphic_eq`, `construction` and `fort`, and the end of a turn and of a game's `timer`,
`dangerous`, `flag`, `inventory`, `heart_broken`, `explore` and `error`, and the history's `auto_awesome`, `build`, `group_add`, `groups`,
`arrow_downward`, `hourglass_bottom`, `volcano` and `sports_kabaddi`), drawn for the game as
white strokes on 24 x 24 and tinted by the node that shows them: Flutter's
Material icons have no equivalent in Godot, and a screen that needs another
glyph adds its SVG here.

`presentation/ui/common/UiIcon` shows one at any size, `ResourceIcon` a
resource's.

## Crisp at several sizes

Godot imports an SVG as a `CompressedTexture2D` rasterised once, at the
import's `svg/scale`; at the default 1.0 a 64 x 64 viewBox gives a 64 px image
that is blurred when drawn at 24 pt on a 3x phone, or at 160 pt. So each
`.svg.import` (committed) sets:

| Folder | `svg/scale` | Raster | Drawn at |
| --- | --- | --- | --- |
| `resources/`, `tech/` | 4 | 256 x 256 | 18 to 64 pt |
| `events/`, `factions/`, `guide/` | 6 | 384 x 384 | up to 160 pt, as illustrations |
| `ui/` | 8 | 192 x 192 | 18 to 28 pt, tinted |

and `mipmaps/generate=true`, with `UiIcon` drawing with
`TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`: the large raster is minified through its
mipmaps instead of being sampled sparsely, which keeps the edges clean at 24 pt
and keeps the detail at 160 pt. A texture is 256 KB to 576 KB with its
mipmaps, loaded when a screen shows it. Rasterising at run time with
`Image.load_svg_from_buffer` would be sharper at one size but needs the `.svg`
in the export (the exports only carry imported resources), and a cache per size.
`tests/icons_test.gd` checks every icon's raster size and mipmaps: a new SVG
copied in without these settings fails it. To add one: copy the SVG, import
the project (`godot --headless --path godot --import`), set `svg/scale` and
`mipmaps/generate` in its `.svg.import`, import again, commit both.
