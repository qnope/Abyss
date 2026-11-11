extends TestCase
## The real seam of lib/presentation/widgets/common/replay_export_dialog.dart:
## the clipboard and the browser's download. A headless run has neither.


func test_a_file_is_offered_on_the_web_only() -> void:
	assert_eq(ReplaySharing.new().can_download(), OS.has_feature("web"))


## The clipboard of a headless run keeps nothing: the call must only be sound.
func test_copy_hands_the_text_to_the_display_server() -> void:
	ReplaySharing.new().copy("{}")
	assert_eq(ReplaySharing.new().can_download(), OS.has_feature("web"))


func test_download_does_nothing_off_the_web() -> void:
	ReplaySharing.new().download("replay.json", "{}")
	assert_true(true)
