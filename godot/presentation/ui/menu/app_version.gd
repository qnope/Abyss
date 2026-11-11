class_name AppVersion
extends RefCounted
## lib/presentation/app_version.dart: the version shown to players, the
## project's (`application/config/version`), which the exports repeat.


## The version, such as "0.1.0".
static func current() -> String:
	return str(ProjectSettings.get_setting("application/config/version", ""))
