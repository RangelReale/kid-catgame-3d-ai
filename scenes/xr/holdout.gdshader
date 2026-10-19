// Makes everything behind it fully transparent. In the headset, transparent
// pixels show the real room (passthrough), so this cuts the level off at the
// edges of the diorama box. It draws after everything else and multiplies
// colour and alpha by zero wherever level geometry lies behind it.
shader_type spatial;
render_mode unshaded, blend_mul, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

void fragment() {
	ALBEDO = vec3(0.0);
	ALPHA = 0.0;
}
