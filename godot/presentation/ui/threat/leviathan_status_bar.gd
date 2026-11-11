class_name LeviathanStatusBar
extends RefreshingPanel
## The red strip under the resource bar on the turn the guardians strike the
## human's Faille: the force, and the units of the level that defends it. A
## touch on it opens the Faille when it is [param tappable]
## (lib/presentation/widgets/leviathan/leviathan_status_bar.dart). It hides
## itself on the other turns.

## A touch on the strip: the Faille under attack, for the map to open on.
signal opened(announcement: LeviathanAnnouncement)

var game: Game
## The attack announced now, null when the strip is hidden.
var announcement: LeviathanAnnouncement
var banner: ThreatBanner


func _init(game_: Game, tappable := false) -> void:
	game = game_
	super()
	banner = ThreatBanner.new(UiIcon.glyph_path(&"warning"), "", "", AbyssColors.ERROR, tappable)
	if tappable:
		banner.tapped.connect(_on_tapped)
	add_child(banner)
	refresh()


func refresh() -> void:
	# Called once by the base class, before the banner is built.
	if banner == null:
		return
	announcement = LeviathanResolver.announced_now(game)
	visible = announcement != null
	if announcement == null:
		return
	var level := announcement.defending_level()
	banner.title_label.text = Texts.t(&"leviathanBannerTitle")
	banner.detail_label.text = Texts.t(&"leviathanBannerForce", {
		"sentinels": LeviathanForce.SENTINELS,
		"level": level,
		"count": ThreatDefenders.on_level(game.human_player(), level),
	})


func _on_tapped() -> void:
	opened.emit(announcement)
