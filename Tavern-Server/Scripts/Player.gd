extends KinematicBody2D

export (int) var speed = 100

var target = Vector2()
var velocity = Vector2()

onready var animate = $AnimationPlayer

func _ready():
	target = position
	
func _unhandled_input(event):
	if event.is_action_pressed('click'):
		target = get_global_mouse_position()

puppet func set_char_pos(id, pos, tar, animation):
	if id != 1 and id != get_tree().get_network_unique_id():
		var moving_player = get_parent().get_node(str(id))
		print(moving_player.name)
		moving_player.position = pos
		moving_player.target = tar
		get_parent().player_info[id].position = pos
		if moving_player.animate.current_animation != animation:
			moving_player.animate.current_animation = animation