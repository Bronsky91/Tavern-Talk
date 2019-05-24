extends Control

func _ready():
	pass

func change_menu_scene(current_scene, new_scene):
	current_scene.visible = false
	new_scene.visible = true



