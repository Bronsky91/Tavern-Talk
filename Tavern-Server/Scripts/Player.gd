extends KinematicBody2D

export (int) var speed = 100

var target = Vector2()
var velocity = Vector2()

onready var animate = $AnimationPlayer

func _ready():
	target = position

remote func update_pos(id, pos, tar, animation):
	position = pos
	target = tar
	get_node("/root/Tavern").player_info[id].position = pos
	if animate.current_animation != animation:
		animate.current_animation = animation
	#rpc_unreliable("client_update_pos", id, pos, tar, animation)