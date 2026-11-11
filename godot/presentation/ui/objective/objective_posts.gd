class_name ObjectivePosts
extends RefCounted
## lib/presentation/extensions/post_holder_extensions.dart
## (ObjectivePostIllustration): the post an objective asks to take, still
## guarded, when it is one.


## The kind of post [param id] asks to take, null for any other objective.
static func type_of(id: ObjectiveId.Value) -> Variant:
	match id:
		ObjectiveId.Value.TAKE_FAILLE:
			return TransitionBaseType.Value.FAILLE
		ObjectiveId.Value.TAKE_CHEMINEE:
			return TransitionBaseType.Value.CHEMINEE
	return null
