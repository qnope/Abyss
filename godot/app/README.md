# app

Startup and navigation: the main scene, building the domain's state, choosing
which screen or world scene shows, and wiring the layers together.

The outermost layer: it may depend on every other one, and none depends on it.

For the 3D prototype, `main.tscn` opens on the base (`presentation/world/`)
with the frame counter and the quality panel over it (`presentation/ui/perf/`):
`QualitySettings` applies the panel's choices, `IdleFrameCap` caps the frame
rate at 30 while the view stands still, and `bench/` runs a fixed orbit when
the launch asks for one: `?bench=1` (`?bench=40` for 40 s) in the web page's
address, `-- --bench[=seconds]` on the command line.

`locale/AppLocale` is the language of the game: it reads the player's
`LanguageSettings` (`data/`), resolves AUTOMATIC from the device
(`OS.get_locale_language()`: French and Spanish as they are, English for any
other) and sets the `TranslationServer`, at startup and each time the setting
changes. `main.gd` builds both. The `.po` files it switches between are made
from the ARB files (`presentation/ui/l10n/README.md`); its `debug_reset()` puts
the language back to French between test files.
