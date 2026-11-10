# presentation/ui/theme

The game's theme, ported from the Flutter one (`lib/presentation/theme/`): the
single source of the interface's styling. `AbyssTheme.build()` makes the
`Theme` in code from the constants here, and `app/main.gd` gives it to the
window at startup, so every control under it inherits it. It is not a `.tres`
file, so that its values have one source and the tests can read them.

## Using it

A control takes a style with `theme_type_variation`, named after the Flutter
role or widget:

- `Label`: `DisplayLarge` … `LabelSmall` (Flutter's `TextTheme` roles),
  `SectionLabel`, `PillLabel`, `DialogTitle`, `AppBarTitle`, `HeroTitle`,
  `HeroSubtitle`, `MenuButtonSubtitle`, `MenuPrimarySubtitle`, `Footnote`,
  `BadgeLabel`, `SegmentDetail`. A plain `Label` reads as `BodyMedium`.
- `Button`: plain is the filled `ElevatedButton`; `OutlinedButton`,
  `TextButton`, `OverMapButton`, `MenuPrimaryButton`, `MenuOutlinedButton`,
  `Segment` (a toggle button in a `ButtonGroup`, inside a `SegmentedTray`).
- `PanelContainer`: plain is the card; `DialogPanel`, `BottomSheetPanel`,
  `AppBarPanel`, `SavePanel`, `SavePanelHighlighted`, `SavePanelFaded`,
  `SegmentedTray`, and `HudPanel`, translucent over the 3D world, with its
  labels `HudHeadline`, `HudFigure` and `HudCaption` (`AbyssHudTheme`, which
  has no Flutter original).
- `LineEdit`: plain, or `ErrorLineEdit` for a field in error. `TextEdit`,
  `ProgressBar`, `HSlider`, `PopupMenu` and tooltips are styled as they are.

Colours are `AbyssColors`, `FactionColors` and `AbyssArmyColors`; durations
and curves are `AbyssMotion`. What a theme cannot hold (a minimum height, a
gap) is a constant of its family, such as `AbyssMenuTheme.BUTTON_MIN_HEIGHT`.

## The palette stays Flutter's

`tests/flutter_palette.json` holds every named constant of the Dart palette
files, written by `tool/flutter_palette.py`; `tests/palette_test.gd` checks
each GDScript constant against it, and `tool/flutter_palette_test.py` that the
fixture is up to date. After a change of the Dart theme, run the script: the
Godot test fails until the port follows.

## Not one to one

- Fonts: Flutter writes bodies in the platform's font; Godot, which ships no
  Roboto, in its default font (`AbyssFonts.Weight.DEFAULT`). Letter spacing,
  border widths and font sizes are whole pixels: 1.5 gives 2, 1.2 gives 1,
  12.5 gives 13. A line height (`TextStyle.height`) is left out.
- Shadows: a Material elevation is a glow as wide as the elevation, at a
  quarter of its colour; a `BoxShadow` is a glow as wide as its blur. Text
  shadows have no blur in Godot: a hard halo half as wide, at a third of the
  opacity. The title's second shadow is its outline.
- Gradients: a `StyleBoxFlat` has none, so the primary menu button is filled
  with the middle of its gradient.
- Buttons take Material 3's overlays (8 % hovered, 10 % pressed or focused,
  drawn over the button for focus); a press has no ripple. Minimum sizes are
  set per node.
- Curves: Godot's tween equations differ from Flutter's Bézier fits by at most
  2–5 % of the move (see `abyss_motion.gd`).
- Not ported yet: the switch (Godot draws it from icons), the floating label
  of a field, the snack bar and the navigation bar, until a screen needs them.
