extends Node2D

export(SpriteFrames) var color_mask = null
export(SpriteFrames) var palettes = null
export(int) var palette_index = 0 setget _set_palette_index
var palette_size = 0 setget _set_palette_size
var _shader_animation
var _label_fps
var _label_info

func _ready():
	_shader_animation = get_node("shader_animations")
	_label_fps = get_node("../hud/label_fps")
	_label_info = get_node("../hud/label_info")
	#StreamTexture doesn't have set_data method, so Change it to ImageTexture, used by random colors (last button)
	#var image_texture = ImageTexture.new()
	#var image = palettes.get_frame("default", 4).get_data()
	#image_texture.create_from_image(image,0)
	#image_texture.storage = ImageTexture.STORAGE_COMPRESS_LOSSLESS
	#palettes.set_frame("default", 4, image_texture)
	#var palette_reference = get_node("../hud/button_random_palette/palette_reference")
	#palette_reference.texture = image_texture
	#self.set_process(true)
	pass


#If the palette index change, reflect the change on the shader and update the width of the new palette
func _set_palette_index(value):
	if(palettes != null && palette_index < palettes.get_frame_count("default")  && palette_index != value):
		palette_index = value
		var frame_mask = palettes.get_frame("default", palette_index)
		get_material().set_shader_param("palette",frame_mask)
		self.palette_size = frame_mask.get_width()

#Update the width of the palette
func _set_palette_size(value):
	if(palette_size != value):
		palette_size = value
		get_material().set_shader_param("palette_size",palette_size)
