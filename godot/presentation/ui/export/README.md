# presentation/ui/export

The replay of a game (lib/presentation/widgets/common/replay_export_dialog.dart
and the domain's `ReplayExport`): a JSON scenario that `bin/simulate.dart` plays
again.

- `ReplayExportDialog`: describes the file (its name, how many actions over how
  many turns, whether every die was recorded) and offers to copy it as text and,
  on the web, to download it. A game older than the journal says it cannot be
  exported. Copying keeps the dialog open and tells so in it; downloading closes
  it.
- `ReplaySharing`: the seam to the clipboard (`DisplayServer.clipboard_set`) and
  to the browser (`JavaScriptBridge.download_buffer`, only where
  `OS.has_feature("web")`). The tests give the dialog a subclass that records
  what it is asked.

Godot has no share sheet: Flutter's "share" is the file on the web only. The
snack bar that confirms the copy is a line in the dialog.
