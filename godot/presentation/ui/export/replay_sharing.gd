class_name ReplaySharing
extends RefCounted
## The two ways a replay leaves the game, behind one seam so that the tests
## never touch the real clipboard nor a browser: the clipboard, and a file the
## browser downloads (Flutter's `Clipboard` and `share_plus`; Godot has no
## share sheet, so a file is offered on the web only). A test hands the dialog
## a subclass that records what it is asked.


## Whether a file can be offered: in the web export, which hands it to the
## browser.
func can_download() -> bool:
	return OS.has_feature("web")


## Puts [param text] on the clipboard.
func copy(text: String) -> void:
	DisplayServer.clipboard_set(text)


## Hands the browser the JSON file [param file_name] holding [param text], which
## it saves where the player's downloads go. Does nothing off the web.
func download(file_name: String, text: String) -> void:
	JavaScriptBridge.download_buffer(text.to_utf8_buffer(), file_name, "application/json")
