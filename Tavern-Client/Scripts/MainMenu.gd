extends Node2D

onready var animate = $AnimationPlayer

func _ready():
	#get_tree().set_auto_accept_quit(false)
	animate.current_animation = 'sign_swing'
		
func change_menu_scene(current_scene, new_scene):
	current_scene.visible = false
	new_scene.visible = true
	
func _unhandled_input(event):
	if (event is InputEventScreenTouch or event.is_action_pressed('click')):
		if $TavernSign_Logo.visible == true:
			change_menu_scene($TavernSign_Logo, $Login)