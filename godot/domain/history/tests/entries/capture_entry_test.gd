extends TestCase
## test/domain/history/entries/capture_entry_test.dart: which captures took
## the volcanic kernel.


func test_capture_entry_is_volcanic_kernel_recognizes_the_kernel_capture() -> void:
	var entry := HistorySamples.capture_entry(CaptureEntry.VOLCANIC_KERNEL)
	assert_true(entry.is_volcanic_kernel())


func test_capture_entry_is_volcanic_kernel_recognizes_the_kernel_capture_of_older_saves() -> void:
	assert_true(HistorySamples.capture_entry("Noyau Volcanique").is_volcanic_kernel())


func test_capture_entry_is_volcanic_kernel_leaves_transition_bases_out() -> void:
	assert_false(HistorySamples.capture_entry("Faille Alpha").is_volcanic_kernel())


## Not in the Dart file: a capture is one unless said otherwise, and keeps
## its fight.
func test_keeps_the_fight_and_whether_it_captured() -> void:
	var fight := HistorySamples.fight(true)
	var won := CaptureEntry.new(6, "Faille Alpha", fight)
	assert_eq([won.turn, won.category], [6, HistoryEntryCategory.Value.CAPTURE])
	assert_true(won.captured)
	assert_true(won.fight_result == fight)
	assert_eq(won.transition_base_name, "Faille Alpha")
	assert_false(CaptureEntry.new(6, CaptureEntry.VOLCANIC_KERNEL, fight, false).captured)
	assert_eq(CaptureEntry.LEGACY_VOLCANIC_KERNEL, "Noyau Volcanique")
