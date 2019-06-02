extends KinematicBody2D

export (int) var speed = 100

var target = Vector2()
var velocity = Vector2()

onready var animate = $AnimationPlayer

func _ready():
	target = position

remote func update_pos(id, pos, tar, animation, _sitting, _sat_down, _h_sit_anim="Left", _v_sit_anim=null):
	position = pos
	target = tar
	get_node("/root/Tavern").player_info[id].position = pos
	get_node("/root/Tavern").player_info[id].sitting = _sitting
	if animate.current_animation != animation.current:
		animate.current_animation = animation.current
	#rpc_unreliable("client_update_pos", id, pos, tar, animation)