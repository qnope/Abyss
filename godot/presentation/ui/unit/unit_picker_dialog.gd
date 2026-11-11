class_name UnitPickerDialog
extends UnitTransferDialog
## A dialog that picks how many units of each type to move, out of
## [param available] (lib/presentation/widgets/unit/unit_picker_dialog.dart):
## the confirm button says "[confirm_label] (total)". Ends with the picks that
## are not zero, or null when it is cancelled.


## A picker called [param title_text] whose button says [param confirm_text],
## with an optional line of [param info] above the rows.
func _init(
	title_text: String, available_: Dictionary[UnitType.Value, Unit], confirm_text: String, info := ""
) -> void:
	var notice: Label = null
	if not info.is_empty():
		notice = Label.new()
		notice.text = info
		notice.theme_type_variation = &"BodySmall"
		notice.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
		notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	super(title_text, available_, func(total: int) -> String: return "%s (%d)" % [confirm_text, total],
		"", null, notice)
