# presentation/ui/common

The UI kit: the components every screen is made of, ported from
`lib/presentation/widgets/common/` and its neighbours. Each is a `Control`
built in code, complete once `_init` returns (no `.tscn`, no `initialize()`),
styled only by the theme (`theme_type_variation`, `AbyssColors`,
`AbyssMotion`...): where a colour is data (a pill's tint) the component builds
its style box with `AbyssBox` from it. Depends on `domain/` and `../theme`,
`../l10n` only.

## Panels, modals and the language

| Component | Role |
| --- | --- |
| `RefreshingPanel` | base of a panel that writes texts: `refresh()` rewrites them when the state changes (the owner calls it) and on `NOTIFICATION_TRANSLATION_CHANGED` (it calls itself), so the language needs no wiring. Draws nothing (`BarePanel`); Godot's automatic translation is off under it |
| `ModalPanel` | what a `ModalLayer` stacks: `placement` (centre, bottom, full), `dismissible`, `fit(area)`, `close(result)` and the `closed(result)` signal, once |
| `ModalLayer` | `open(modal)`, `close_top()`, `top()`, `depth()`: each modal over a scrim of its own, touches let through while empty, a touch on the scrim or Escape closes the top one when dismissible, a short fade in unless `reduced_motion`. A flow is `closed` connected to the next `open`, never an `await` |
| `AbyssDialog` | title, `body` that scrolls past 90 % of the screen, `add_action(text, result, variation)` ending it with the result, `add_button(text, variation)` leaving it open |
| `MessageDialog` | a line of news and an OK, where Flutter shows a snack bar (a descent done, the garrison's size, an action refused): the text is a function, so it follows the language |
| `BottomSheet` | `SheetDragHandle` (a pull of 64 px dismisses it) over a scrolling `body`, the full width |
| `FullPage` | app bar (back button, centred title) over a padded scrolling `body`; back ends it with null |
| `PageBar` | the app bar of both pages: a back button and a centred title (`back_pressed`, `set_title`) |
| `ScreenPage` | a screen that is a page, not stacked on the modals: a `PageBar` over a `body`, on the `PageVeil` that dims the world; `back_pressed` from the arrow or Escape. The title is an ARB key, so that it follows the language |
| `ScrollBody` | the column inside them: as tall as its content up to `max_height` |
| `IllustratedCard` / `IllustratedCardBody` | the dialog of a card with a picture, a title, lines and stacked actions; the body alone for a card with a frame of its own |

## Pictures

- `UiIcon(path, size, tint)` shows an SVG of `assets/icons/` square, drawn with
  its mipmaps (`assets/icons/README.md` says why and how it stays crisp);
  `UiIcon.glyph(name)` a tinted glyph of `assets/icons/ui/`. `ResourceIcon(type,
  size)` is a resource's.
- `Portrait(name, size, tint)` is the stand-in for the 3D renders of buildings,
  units and monsters until step 7: a tinted panel with the initials of the
  name. Never an SVG: the world's art comes from the models.

## Small components

`InfoBadge` (a line of text and an icon in a box rimmed with a colour, the
base's banners), `StatusPill`, `CountBadge`, `NoticeBanner`, `ThreatBanner` (a `tapped` signal
when tappable), `SegmentedBar` of `SegmentItem`s (a `chosen` signal),
`LabeledSwitch` (a `toggled` signal), `ChipRow` (filter chips, a `chosen` signal), `StripLine` (a glyph and a short text of a
status strip), `LoreText` (dimmed italics, the Body
font leaned), `GuideHalo` (a pulsing cyan halo around any control while
`active`; a rounded rectangle or circle, not Flutter's traced paths) and
`TabPlaceholder` ("coming soon" follows the language). `Greyscale` turns any
icon grey with a shader (a locked or given-up technology).

## Not one to one

- A text a component receives is written once: a screen that must follow the
  language derives from `RefreshingPanel` and rebuilds what it passes in
  `refresh()`. Only `TabPlaceholder` and `FullPage` write a text of their own.
- Flutter's `Icon(Icons.x)` becomes a path to an SVG; the Material icons the
  game uses are drawn as they are needed (`assets/icons/ui/`).
- A segment's label too wide is cut with an ellipsis, not scaled down.
- A `SheetDragHandle` row is 32 high where Flutter's bar has 8 above and 4
  below, so that a finger finds it.
- The dialog and the illustrated card pad by the theme's 24, Flutter's card
  by 20.

The tests are in `tests/`, on `UiTestCase` (`tool/test/README.md`).
`tool/scene_capture.sh` renders the kit (`tool/scene/README.md`).
