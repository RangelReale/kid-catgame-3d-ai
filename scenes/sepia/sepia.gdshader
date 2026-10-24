shader_type canvas_item;

// Paints what is behind it in shades of brown, like an old photo.

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
// The brown that the brightest parts of the picture turn into.
uniform vec4 tint : source_color = vec4(1.0, 0.86, 0.62, 1.0);
// How much of the brown to show: 0 is the normal picture, 1 is all brown.
uniform float amount : hint_range(0.0, 1.0) = 1.0;
// How much to darken the picture, so the words on top stand out.
uniform float darken : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	vec3 sepia = gray * tint.rgb * (1.0 - darken);
	COLOR = vec4(mix(color, sepia, amount), 1.0);
}
