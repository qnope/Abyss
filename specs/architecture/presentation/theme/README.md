# Theme

`lib/presentation/theme/` — Centralized deep-sea design system.

## Overview

`AbyssTheme.create()` returns a complete `ThemeData` configured for Material 3 dark mode. All screens and widgets consume this theme — no hardcoded colors or styles.

## Files

| File | Purpose |
|------|---------|
| `abyss_theme.dart` | Master `ThemeData` builder. Assembles color scheme, text, buttons, cards, inputs, navigation. |
| `abyss_colors.dart` | Color palette constants organized in groups. |
| `abyss_text_theme.dart` | Typography definitions. |
| `abyss_button_theme.dart` | Elevated, outlined, text, and icon button styles. |
| `abyss_card_theme.dart` | Card, dialog, bottom sheet, and app bar themes. |
| `abyss_input_theme.dart` | Input decoration, slider, and progress indicator themes. |

## Color Palette

| Group | Colors |
|-------|--------|
| Backgrounds | `abyssBlack`, `deepNavy`, `oceanFloor`, `trench` |
| Bioluminescent | `biolumCyan` (primary), `biolumBlue`, `biolumTeal`, `biolumPurple`, `biolumPink` |
| Resources | `algaeGreen`, `coralPink`, `oreBlue`, `energyYellow`, `pearlWhite` |
| Surfaces | `surfaceLight`, `surfaceDim`, `surfaceBright` |
| Terrain | `reefPink`, `plainBlue`, `rockGray`, `faultBlack` |
| Functional | `success`, `warning`, `error`, `onSurface`, `onSurfaceDim`, `disabled` |

## How to Use

Apply theme in `MaterialApp`:

```dart
MaterialApp(theme: AbyssTheme.create(), ...)
```

Access colors directly: `AbyssColors.biolumCyan`
