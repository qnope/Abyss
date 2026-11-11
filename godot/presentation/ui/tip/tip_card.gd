class_name TipCard
extends IllustratedCard
## The dialog of a « première fois » tip (lib/.../tip_card.dart): its
## illustration, its title, its lines and a button to close it. It changes
## nothing: opened from the Guide it is read again.

var tip: Tip


func _init(tip_: Tip) -> void:
	tip = tip_
	super(TipIllustrations.new().of(tip.id, ILLUSTRATION_SIZE), TipTexts.title(tip.id), TipTexts.lines(tip.id))
	add_action(Texts.t(&"commonGotIt"), null, &"")
