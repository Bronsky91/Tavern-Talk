shader_type canvas_item;
render_mode unshaded;

uniform sampler2D PaletteSwap : hint_albedo;

void fragment()
{
	vec4 old_color = texture(TEXTURE, UV);
	vec2 swap_coord = vec2 ( old_color.r, 0);
	vec4 new_color = texture(PaletteSwap, swap_coord);
	new_color.a *= old_color.a;
	COLOR = new_color;
}