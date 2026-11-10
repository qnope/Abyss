// The deep sea around the base, as its sky: the water lit from the surface
// overhead, a haze of light around the light's way down, fading to the
// abyss below. Its radiance is the scene's ambient light. No TIME: Godot
// then computes its radiance once, not every frame.
shader_type sky;

uniform vec3 surface_colour : source_color = vec3(0.16, 0.42, 0.52);
uniform vec3 horizon_colour : source_color = vec3(0.05, 0.19, 0.28);
uniform vec3 abyss_colour : source_color = vec3(0.008, 0.035, 0.07);
uniform float light_haze = 0.5;

void sky() {
	float up = EYEDIR.y;
	vec3 colour = mix(horizon_colour, surface_colour, smoothstep(0.0, 1.0, up));
	colour = mix(colour, abyss_colour, smoothstep(0.0, 1.0, -up));
	float toward = max(dot(EYEDIR, LIGHT0_DIRECTION), 0.0);
	colour += surface_colour * light_haze * pow(toward, 6.0);
	COLOR = colour;
}
