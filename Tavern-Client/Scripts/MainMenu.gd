extends Node2D

class_name MainMenu

onready var animate: AnimationPlayer = $AnimationPlayer

func _ready():
	get_tree().set_auto_accept_quit(false)
	animate.current_animation = 'sign_swing'
	a.turn_on('menu')
		
func change_menu_scene(current_scene, new_scene) -> void:
	current_scene.visible = false
	new_scene.visible = true
	
func _unhandled_input(event):
	if (event is InputEventScreenTouch or event.is_action_pressed('click')):
		if $TavernSign_Logo.visible == true:
			change_menu_scene($TavernSign_Logo, $Login)

func _notification(notif):
	if notif == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST or notif == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		for scene in get_children():
			if scene.get('visible'):
				if scene.name == 'Login' and scene.visible:
					change_menu_scene(scene, get_node("TavernSign_Logo"))
				elif scene.name == 'Register' and scene.visible:
					change_menu_scene(scene, get_node("Login"))
				elif scene.name == 'TavernMenu' and scene.visible:
					change_menu_scene(scene, get_node("CharacterSelect"))
				elif scene.name == 'CharacterSelect' and scene.visible:
					change_menu_scene(scene, get_node("Login"))
				elif scene.name == 'CharacterCreate' and scene.get_child(1).visible and scene.visible:
					change_menu_scene(scene, get_node("CharacterSelect"))
				elif scene.name == 'CharacterCreate' and scene.get_child(4).visible and scene.visible:
					change_menu_scene(scene.get_child(4), get_node("CharacterCreate").get_child(1))
				elif scene.name == 'CreateTavern' and scene.visible:
					change_menu_scene(scene, get_node("TavernMenu"))
				elif scene.name == 'TavernSign_Logo' and scene.visible:
					get_tree().quit()