# presentation/ui/theme

The game's theme, ported from the Flutter one (`lib/presentation/theme/`): the
single source of the interface's styling. `AbyssTheme.build()` makes the
`Theme` in code from the constants here, and `app/app.gd` gives it to the
window at startup, so every control under it inherits it. It is not a `.tres`
file, so that its values have one source and the tests can read them.

## Using it

A control takes a style with `theme_type_variation`, named after the Flutter
role or widget:

- `Label`: `DisplayLarge` … `LabelSmall` (Flutter's `TextTheme` roles),
  `SectionLabel`, `PillLabel`, `DialogTitle`, `AppBarTitle`, `HeroTitle`,
  `HeroSubtitle`, `MenuButtonLabel` and `MenuPrimaryLabel` (the label of a menu
  button drawn over it), `MenuButtonSubtitle`, `MenuPrimarySubtitle`, `Footnote`,
  `BadgeLabel`, `SegmentName`, `SegmentDetail`, and `Lore`, `LoreLarge`,
  `LoreSmall` (the Body roles dimmed and leaned: `AbyssTextStyle.slant`, since
  no font of the game has an italic face). A plain `Label` reads as
  `BodyMedium`.
- `Button`: plain is the filled `ElevatedButton`; `OutlinedButton`,
  `TextButton`, `OverMapButton`, `MenuPrimaryButton`, `MenuOutlinedButton`,
  `Segment` (a toggle button in a `ButtonGroup`, inside a `SegmentedTray`),
  `HudToggle` (a switch over the 3D world, tinted and rimmed when on),
  `ChipButton` and `ChipButtonActive` (`AbyssChipTheme`: the small chips of the
  map's level selector, the lit one filled with cyan).
- `PanelContainer`: plain is the card; `DialogPanel`, `BottomSheetPanel`,
  `AppBarPanel`, `SavePanel`, `SavePanelHighlighted`, `SavePanelFaded`,
  `SegmentedTray`, and `HudPanel`, translucent over the 3D world, with its
  labels `HudHeadline`, `HudFigure` and `HudCaption` (`AbyssHudTheme`, which
  has no Flutter original).
- `LineEdit`: plain, or `ErrorLineEdit` for a field in error. `TextEdit`,
  `ProgressBar` (and `NoiseGauge`, its warning-coloured variation, the raid's
  gauge), `HSlider`, `PopupMenu` and tooltips are styled as they are.
- Surfaces (`AbyssSurfaceTheme`): `Panel` `ModalScrim` (behind a modal),
  `Panel` `PageVeil` (darker, under a screen's forms and lists),
  `PanelContainer` `BarePanel` (draws nothing, only lays out), `Button`
  `TapSurface` (a touch area lit when pointed at or pressed), the dividers
  (`HSeparator`, `VSeparator`) and the scrollbars, as they are.
- `AbyssGuideTheme.halo(pulse, radius, inset)`: the style box of the guide's
  halo at a point of its pulse; `GuideHalo` animates it.
- `CheckButton` `Switch` (`AbyssSwitchTheme`): the switch, whose four icons
  are drawn in code.
- Chrome (`AbyssChromeTheme`): `PanelContainer` `SnackBarPanel` with the
  `Label` `SnackBarLabel`, `NavigationBarPanel`, and `Button` `NavigationItem`
  (a destination of the navigation bar, in a `ButtonGroup`).

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
- The switch is drawn in code as the CheckButton's icons (52 x 32, Material
  3's), the snack bar and the navigation bar are styles only: no animation of
  the thumb, and every name of the navigation bar is in 600 where Flutter
  writes the unselected ones in the regular weight.
- Not ported yet: the floating label of a field, until a screen needs it.
