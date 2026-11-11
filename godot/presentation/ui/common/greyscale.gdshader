shader_type canvas_item;
// Draws what it is on in greys: an unavailable icon (Flutter's greyscale
// bitmap). The alpha and the tint of the node are kept.

void fragment() {
	float luma = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(vec3(luma), COLOR.a);
}
