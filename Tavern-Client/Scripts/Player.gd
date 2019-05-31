extends KinematicBody2D

export (int) var speed = 100

var target = Vector2()
var velocity = Vector2()
var gender = null
var style = null
var busy
var movement_buffer = 30
var sitting = false
var sat_down = false

onready var animate = $AnimationPlayer

func _ready():
	target = position
	animate.current_animation = 'idle_up'
	use_texture('idle')
	
### Movement ###

func _unhandled_input(event):
	if not busy and (event is InputEventScreenTouch or event.is_action_pressed('click')):
		target = event.position
	
puppet func update_pos(id, pos, tar, animation):
	position = pos
	target = tar
	get_node("/root/Tavern").player_info[id].position = pos
	if animate.current_animation != animation:
			animate.current_animation = animation
	if 'walk' in animate.current_animation:
		use_texture('walking')
	else:
		use_texture('idle')
		
func _physics_process(delta):
	if is_network_master():
		velocity = (target - position).normalized() * speed
		#print((target - position).length())
		if (target - position).length() > movement_buffer: 
			move_and_slide(velocity)
			use_texture('walking')
			if velocity.angle() > -2 and velocity.angle() < -1:
				animate.current_animation = 'walk_up'
			if velocity.angle() > 1 and velocity.angle() < 2:
				animate.current_animation = 'walk_down'
			if velocity.angle() < -2 or velocity.angle() > 2:
				animate.current_animation = 'walk_left'
			if velocity.angle() > -1 and velocity.angle() < 1:
				animate.current_animation = 'walk_right'
			rpc_unreliable("update_pos", get_tree().get_network_unique_id(), position, target, animate.current_animation)
		elif (target - position).length() < movement_buffer and sitting == true and sat_down == false:
			use_texture('sitting')
			animate.current_animation = 'left_sit_back'
			sat_down = true
			rpc_unreliable("update_pos", get_tree().get_network_unique_id(), position, target, animate.current_animation)
		elif (target - position).length() < movement_buffer and sitting == false:
			use_texture('idle')
			if animate.current_animation == 'walk_up':
				animate.current_animation = 'idle_up'
			if animate.current_animation == 'walk_down':
				animate.current_animation = 'idle_down'
			if animate.current_animation == 'walk_left':
				animate.current_animation = 'idle_left'
			if animate.current_animation == 'walk_right':
				animate.current_animation = 'idle_right'
			rpc_unreliable("update_pos", get_tree().get_network_unique_id(), position, target, animate.current_animation)
			
func use_texture(animation):
		if animation == 'walking':
			$Body.set_texture(load("res://Assets/Characters/"+gender+"_Walk_00"+str(style.skin)+".png"))
			$Body.vframes = 4
			$Body.hframes = 6
			$Body/Hair.set_texture(load("res://Assets/Characters/"+gender+"_WalkHair_00"+str(style.hair)+".png"))
			$Body/Hair.vframes = 4
			$Body/Hair.hframes = 6
			$Body/Eyes.set_texture(load("res://Assets/Characters/"+gender+"_WalkEyes_00"+str(style.eyes)+".png"))
			$Body/Eyes.vframes = 4
			$Body/Eyes.hframes = 6
			$Body/Clothes.set_texture(load("res://Assets/Characters/"+gender+"_WalkClothes_00"+str(style.clothes)+".png"))
			$Body/Clothes.vframes = 4
			$Body/Clothes.hframes = 6
		elif animation == 'idle':
			$Body.set_texture(load("res://Assets/Characters/"+gender+"_Idle_00"+str(style.skin)+".png"))
			$Body.vframes = 4
			$Body.hframes = 4
			$Body/Hair.set_texture(load("res://Assets/Characters/"+gender+"_IdleHair_00"+str(style.hair)+".png"))
			$Body/Hair.vframes = 4
			$Body/Hair.hframes = 4
			$Body/Eyes.set_texture(load("res://Assets/Characters/"+gender+"_IdleEyes_00"+str(style.eyes)+".png"))
			$Body/Eyes.vframes = 4
			$Body/Eyes.hframes = 4
			$Body/Clothes.set_texture(load("res://Assets/Characters/"+gender+"_IdleClothes_00"+str(style.clothes)+".png"))
			$Body/Clothes.vframes = 4
			$Body/Clothes.hframes = 4
		elif animation == 'sitting':
			$Body.set_texture(load("res://Assets/Characters/"+gender+"_LeftSide_Sit_00"+str(style.skin)+".png"))
			$Body.vframes = 4
			$Body.hframes = 9
			$Body/Hair.set_texture(load("res://Assets/Characters/"+gender+"_LeftSide_SitHair_00"+str(style.hair)+".png"))
			$Body/Hair.vframes = 4
			$Body/Hair.hframes = 9
			$Body/Eyes.set_texture(load("res://Assets/Characters/"+gender+"_LeftSide_SitEyes_00"+str(style.eyes)+".png"))
			$Body/Eyes.vframes = 4
			$Body/Eyes.hframes = 9
			$Body/Clothes.set_texture(load("res://Assets/Characters/"+gender+"_LeftSide_SitClothes_00"+str(style.clothes)+".png"))
			$Body/Clothes.vframes = 4
			$Body/Clothes.hframes = 9

func sit_down(t):
	$LowerBody.disabled = true
	movement_buffer = 1
	target = t
	sitting = true
### Chatting ###

sync func receive_tavern_chat(msg, id):
	get_parent().get_node(str(id)).overhead_chat(msg)

func overhead_chat(msg):
	$ChatBubble.bbcode_text = ""
	$ChatBubble.hint_tooltip = msg
	msg = "[center]"+msg+"[/center]"
	$ChatBubble.bbcode_text = msg
	$ChatBubble/ChatTimer.start(5)

func _on_ChatTimer_timeout():
	$ChatBubble.clear()

func _on_AnimationPlayer_animation_finished(anim_name):
	print('sit' in 'left_sit_back')
	if 'left_sit_back' == anim_name:
		animate.stop()
