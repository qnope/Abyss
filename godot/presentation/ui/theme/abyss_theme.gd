class_name AbyssTheme
## The game's theme, the single source of the interface's styling: every
## family of styles ported from lib/presentation/theme/, gathered into one
## Theme built in code, so that its values have one source and the tests
## can read them. app/main.gd gives it to the window at startup.


## A new Theme holding every style of the game.
static func build() -> Theme:
	var theme := Theme.new()
	AbyssTextTheme.apply(theme)
	AbyssButtonTheme.apply(theme)
	AbyssCardTheme.apply(theme)
	AbyssPopupTheme.apply(theme)
	AbyssInputTheme.apply(theme)
	AbyssSegmentedTheme.apply(theme)
	AbyssMenuTheme.apply(theme)
	AbyssHudTheme.apply(theme)
	AbyssSurfaceTheme.apply(theme)
	AbyssSwitchTheme.apply(theme)
	AbyssChromeTheme.apply(theme)
	return theme
