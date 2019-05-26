extends Control

onready var animate = $AnimationPlayer

func _ready():
	animate.current_animation = 'sign_swing'

func change_menu_scene(current_scene, new_scene):
	current_scene.visible = false
	new_scene.visible = true



