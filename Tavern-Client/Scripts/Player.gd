extends KinematicBody2D

export (int) var speed = 100

var target = Vector2()
var velocity = Vector2()

onready var animate = $AnimationPlayer

func _ready():
	target = position
	animate.current_animation = 'walk_up' # Should be idle

func _unhandled_input(event):
	if event.is_action_pressed('click'):
		target = get_global_mouse_position()

func _physics_process(delta):
	velocity = (target - position).normalized() * speed
	if (target - position).length() > 5: 
		move_and_slide(velocity)
	else:
		pass
		## Idle animation
	if velocity.angle() > -2 and velocity.angle() < -1:
		animate.current_animation = 'walk_up'
	if velocity.angle() > 1 and velocity.angle() < 2:
		animate.current_animation = 'walk_down'
	if velocity.angle() < -2 or velocity.angle() > 2:
		animate.current_animation = 'walk_left'
	if velocity.angle() > -1 and velocity.angle() < 1:
		animate.current_animation = 'walk_right'