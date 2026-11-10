// A ray of light from the surface: a ribbon along the ray's axis, turned to
// face the camera, drawn additively with a soft profile across. Strongest
// near the surface and gone a few metres under the deck, faded close to the
// camera, far from it and when seen along its axis, its strength wavering
// slowly. No light, shadow or fog: it costs a few pixels of blending.
shader_type spatial;
render_mode blend_add, unshaded, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform vec3 colour : source_color = vec3(0.55, 0.85, 1.0);
uniform float strength = 0.2;
// The wavering's speed, in radians per second.
uniform float sway = 0.5;
// The ribbon's width at the surface end and at the deep end, in metres.
uniform vec2 widths = vec2(1.5, 8.0);
// The heights, in metres, between which the ray fades out downwards.
uniform vec2 depth_fade = vec2(-16.0, 4.0);
// The distances to the camera, in metres, between which it fades in, and out.
uniform vec2 near_fade = vec2(4.0, 14.0);
uniform vec2 far_fade = vec2(60.0, 110.0);

varying float phase;
varying float height;
varying float distance_to_eye;
varying float along_view;

void vertex() {
	// The instance's y axis is the ray, as long as the ray.
	vec3 axis = normalize(MODEL_MATRIX[1].xyz);
	vec3 centre = (MODEL_MATRIX * vec4(0.0, VERTEX.y, 0.0, 1.0)).xyz;
	vec3 to_eye = CAMERA_POSITION_WORLD - centre;
	vec3 side = normalize(cross(axis, to_eye));
	float width = mix(widths.y, widths.x, VERTEX.y + 0.5) * INSTANCE_CUSTOM.y;
	vec3 world = centre + side * VERTEX.x * width;
	phase = INSTANCE_CUSTOM.x * 6.2832;
	height = world.y;
	distance_to_eye = length(to_eye);
	along_view = abs(dot(axis, normalize(to_eye)));
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world, 1.0);
}

void fragment() {
	float profile = sin(UV.x * 3.14159);
	profile *= profile;
	float depth = smoothstep(depth_fade.x, depth_fade.y, height);
	float near = smoothstep(near_fade.x, near_fade.y, distance_to_eye);
	float far = 1.0 - smoothstep(far_fade.x, far_fade.y, distance_to_eye);
	float across = 1.0 - smoothstep(0.7, 0.97, along_view);
	float waver = 0.65 + 0.35 * sin(TIME * sway + phase + height * 0.15);
	ALBEDO = colour;
	ALPHA = clamp(profile * depth * near * far * across * waver * strength, 0.0, 1.0);
}
