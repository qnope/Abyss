class_name GlowTitle
extends VBoxContainer
## A screen title glowing like bioluminescence, with an optional subtitle in
## small capitals below (lib/presentation/widgets/menu/glow_title.dart). The
## glow and the spacing of the letters are the theme's (HeroTitle,
## HeroSubtitle).

const GAP := 10

var title_label := Label.new()
var subtitle_label := Label.new()


func _init(title_text: String, subtitle := "") -> void:
	add_theme_constant_override(&"separation", GAP)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.theme_type_variation = &"HeroTitle"
	subtitle_label.theme_type_variation = &"HeroSubtitle"
	for line: Label in [title_label, subtitle_label]:
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(line)
	title_label.text = title_text
	set_subtitle(subtitle)


## Writes the subtitle in capitals; none is shown when it is empty.
func set_subtitle(text_written: String) -> void:
	subtitle_label.text = text_written.to_upper()
	subtitle_label.visible = not text_written.is_empty()
