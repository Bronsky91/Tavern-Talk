extends KinematicBody2D

export (int) var speed = 100

var target = Vector2()
var velocity = Vector2()

onready var animate = $AnimationPlayer

func _ready():
	target = position
	print(is_network_master())
	
func _unhandled_input(event):
	if event.is_action_pressed('click'):
		target = get_global_mouse_position()

puppet func update_pos(id, pos, tar, animation):
	position = pos
	target = tar
	get_parent().player_info[id].position = pos
	if animate.current_animation != animation:
			animate.current_animation = animation
		
func _physics_process(delta):
	if is_network_master():
		velocity = (target - position).normalized() * speed
		if velocity.angle() > -2 and velocity.angle() < -1:
			animate.current_animation = 'walk_up'
		if velocity.angle() > 1 and velocity.angle() < 2:
			animate.current_animation = 'walk_down'
		if velocity.angle() < -2 or velocity.angle() > 2:
			animate.current_animation = 'walk_left'
		if velocity.angle() > -1 and velocity.angle() < 1:
			animate.current_animation = 'walk_right'
		if (target - position).length() > 5: 
			move_and_slide(velocity)
			rpc_unreliable("update_pos", get_tree().get_network_unique_id(), position, target, animate.current_animation)
		else:
			pass
		## Idle animation
