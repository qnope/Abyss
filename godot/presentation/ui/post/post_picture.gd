class_name PostPicture
extends RefCounted
## The picture of a Faille or a Cheminée on its sheet (lib/presentation/
## extensions/post_holder_extensions.dart, `svgPathFor`): the initials of its
## kind on a [Portrait] tinted by whoever holds it, until step 7 fills it with
## the render of the model. The 3D map shows the same holders through
## `MapLooks`.

const SIZE := 80.0


## The picture of a post of [param type] held by [param holder].
static func of(type: TransitionBaseType.Value, holder: PostHolder.Value, size := SIZE) -> Portrait:
	return Portrait.new(TransitionBaseTexts.display_name(type), size, PassagePicture.tint_of(holder))
