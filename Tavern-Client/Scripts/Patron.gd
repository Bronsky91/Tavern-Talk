extends KinematicBody2D

class_name Patron

export (int) var speed: int = 115

var target: Vector2
var velocity: Vector2
var gender: String
var style: Dictionary
var anim # State tracker for animations

var busy: bool = false setget set_busy ,is_busy
var npc: bool = false setget set_npc, is_npc
var character_name: String
var movement_buffer: int = 30
var sat_down: bool = false
var sitting: bool = false

var stool_dict: Dictionary = {'table': null, 'stool': null}
var current_table_id = null

var h_sit_anim: String
var v_sit_anim: String
var a_texture: String

var npc_type: Dictionary

onready var animate: AnimationPlayer = $AnimationPlayer
onready var name_plate: RichTextLabel = $NamePlate


func _ready():
	if npc:
		default_npc_animation()
		name_plate.bbcode_text = "[center][color=#66ccff]"+npc_type.name
		#receive_tavern_chat("Welcome!", npc_type.name)
	if not npc:
		name_plate.bbcode_text = "[center][color=#66ccff]"+character_name
		# When character loads on other's screens it displays the correct animation
		# If they're brand new to the tavern then it's idle up
		target = position
		if anim == null:
			animate.current_animation = 'idle_up'
			use_texture('idle')
		else:
			if 'sat' in anim.current:
				# Sat is not a real animation but a state of the character sitting at the table not moving
				if anim.v_sit_anim != null:
					v_sit_anim = anim.v_sit_anim 
				if anim.h_sit_anim != null:
					h_sit_anim = anim.h_sit_anim
				use_texture('sitting')
				animate.play('sit_'+v_sit_anim, -1, 0, true)
				#Playing the end of the animation at 0 speed
			else:
				animate.current_animation = anim.current
				use_texture(anim.texture)
				# play the proper non sit animation
	
func init(_gender: String, _style: Dictionary, _animation, _character_name: String) -> void:
	# inits the player state from the tavern configure_player function
	style = _style
	gender = _gender
	anim = _animation
	character_name = _character_name

func set_npc(_npc: bool) -> void:
	npc = _npc
	
func is_npc() -> bool:
	return npc

func set_busy(_busy: bool) -> void:
	busy = _busy

func is_busy() -> bool:
	return busy
	
### Movement ###

func _unhandled_input(event):
	if not npc and not busy and (event is InputEventScreenTouch or event.is_action_pressed('click')):
		target = event.position

puppet func update_pos(id: int, pos: Vector2, tar: Vector2, animation: Dictionary) -> void:
	position = pos
	target = tar
	anim = animation # animation is the state object passed whenver the player moves
	get_node("/root/Tavern").player_info[id].position = pos # tells new players where this player is
	get_node("/root/Tavern").player_info[id].animation = animation # tells new players what animation this player is doing
	stool_dict['table'] = animation.stool_dict.table #keeps the table stools organized
	stool_dict['stool'] = animation.stool_dict.stool #state is either filled or vacant
	# Checks the animation state object to see which texture to use
	if 'walk' in animation.current:
		use_texture('walking')
	elif 'idle' in animation.current:
		use_texture('idle')
	elif 'sit' in animation.current:
		# Sets sitting texture for up or down
		# TODO: include left or right when added to game
		if animation.v_sit_anim != null:
			v_sit_anim = animation.v_sit_anim 
		if animation.h_sit_anim != null:
			h_sit_anim = animation.h_sit_anim
		use_texture('sitting')
	
	# Play the proper animation
	if animation.backwards == false and animate.current_animation != animation.current and not animation.stop: # Stop is set when the sitting animation is done
		if 'sat' == animation.current:
			# Since 'sat' is not a proper animation but a state keeper, 
				# switches the current animation to sit_
			use_texture('sitting')
			animation.current = 'sit_'+v_sit_anim
		animate.current_animation = animation.current
	if animation.backwards:
		animate.play_backwards(animate.current_animation)
		busy = true
	if animation.timer != null:
		$AnimationTimer.start(animation.timer)

func _physics_process(delta):
	if is_network_master():
		# Only network masters should be using the movement rpc calls
		velocity = (target - position).normalized() * speed
		if (target - position).length() > movement_buffer: 
			move_and_slide(velocity)
			use_texture('walking')
			a_texture = 'walking'
			# plays the proper animation depending on the angle the player is moving
			if velocity.angle() > -2 and velocity.angle() < -1:
				animate.current_animation = 'walk_up'
			if velocity.angle() > 1 and velocity.angle() < 2:
				animate.current_animation = 'walk_down'
			if velocity.angle() < -2 or velocity.angle() > 2:
				animate.current_animation = 'walk_left'
			if velocity.angle() > -1 and velocity.angle() < 1:
				animate.current_animation = 'walk_right'
			rpc_unreliable("update_pos", get_tree().get_network_unique_id(), position, target, {'current':animate.current_animation, 'backwards': false, 'stool_dict': stool_dict, 'timer': null, 'texture': a_texture, 'sat_down': sat_down, 'sitting': sitting, 'h_sit_anim': h_sit_anim, 'v_sit_anim':v_sit_anim, 'stop': false})
		elif (target - position).length() < movement_buffer and sitting == true and sat_down == false:
			use_texture('sitting')
			a_texture = 'sitting'
			animate.current_animation = 'sit_'+v_sit_anim
			sat_down = true
			$AnimationTimer.start(1.1) # This timer is for the z-index of the stool the player is sitting on
			if v_sit_anim == 'back':
				# TODO: include conditionals for left and right when added to the game
				get_node("../Table_00"+str(stool_dict.table)+"/Stool_00"+str(stool_dict.stool)).z_index = 1
			rpc_unreliable("update_pos", get_tree().get_network_unique_id(), position, target, {'current':animate.current_animation, 'backwards': false, 'stool_dict': stool_dict, 'timer': 1.1, 'texture': a_texture, 'sat_down': sat_down, 'sitting': sitting, 'h_sit_anim': h_sit_anim, 'v_sit_anim':v_sit_anim, 'stop': false})
		elif (target - position).length() < movement_buffer and sitting == false:
			use_texture('idle')
			a_texture = 'idle'
			# When player comes to a stop, transition to the proper idle direction based on the last animation
			if animate.current_animation == 'walk_up':
				animate.current_animation = 'idle_up'
			if animate.current_animation == 'walk_down':
				animate.current_animation = 'idle_down'
			if animate.current_animation == 'walk_left':
				animate.current_animation = 'idle_left'
			if animate.current_animation == 'walk_right':
				animate.current_animation = 'idle_right'
			rpc_unreliable("update_pos", get_tree().get_network_unique_id(), position, target, {'current':animate.current_animation, 'backwards': false, 'stool_dict': stool_dict, 'timer': null,  'texture': a_texture, 'sat_down': sat_down, 'sitting': sitting, 'h_sit_anim': h_sit_anim, 'v_sit_anim':v_sit_anim, 'stop': false})

func use_texture(animation: String) -> void:
	# called to set the proper texture and frames when animation changes
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
		$Body.set_texture(load("res://Assets/Characters/"+gender+"_"+h_sit_anim+"Side_Sit_00"+str(style.skin)+".png"))
		$Body.vframes = 4
		$Body.hframes = 9
		$Body/Hair.set_texture(load("res://Assets/Characters/"+gender+"_"+h_sit_anim+"Side_SitHair_00"+str(style.hair)+".png"))
		$Body/Hair.vframes = 4
		$Body/Hair.hframes = 9
		$Body/Eyes.set_texture(load("res://Assets/Characters/"+gender+"_"+h_sit_anim+"Side_SitEyes_00"+str(style.eyes)+".png"))
		$Body/Eyes.vframes = 4
		$Body/Eyes.hframes = 9
		$Body/Clothes.set_texture(load("res://Assets/Characters/"+gender+"_"+h_sit_anim+"Side_SitClothes_00"+str(style.clothes)+".png"))
		$Body/Clothes.vframes = 4
		$Body/Clothes.hframes = 9

func sit_down(t: Vector2, _stool: int, table_id: int) -> void:
	# Called from tavern when joining a table
	stool_dict = {'table': table_id, 'stool': _stool}
	current_table_id = table_id
	$LowerBody.disabled = true
	movement_buffer = 1
	target = t
	sat_down = false
	sitting = true
	busy = true
	
func stand_up(_stool: int, table_id: int) -> void:
	# Called from Tavern when leaving a table
	stool_dict = {'table': table_id, 'stool': _stool}
	$LowerBody.disabled = false
	movement_buffer = 30 # Reverts the buffer to 30 since not directing player to stool
	animate.play_backwards(animate.current_animation)
	busy = true
	$AnimationTimer.start(.7) # timer for z-index of stool
	if is_network_master():
		rpc_unreliable("update_pos", get_tree().get_network_unique_id(), position, target, {'current':animate.current_animation, 'backwards': true, 'stool_dict': stool_dict, 'timer': .7, 'texture': a_texture, 'sat_down': sat_down, 'sitting': sitting, 'h_sit_anim': h_sit_anim, 'v_sit_anim':v_sit_anim, 'stop': false})
		
func _on_AnimationPlayer_animation_finished(anim_name: String):
	if 'sit' in anim_name and animate.get_current_animation_position() > 0:
	# if animation is finishing normally
		animate.stop()
		#busy = false
		use_texture('sitting')
		if is_network_master():
			rpc_unreliable("update_pos", get_tree().get_network_unique_id(), position, target, {'current':'sat', 'backwards': false, 'stool_dict': stool_dict, 'timer': null,  'texture': a_texture, 'sat_down': sat_down, 'sitting': sitting, 'h_sit_anim': h_sit_anim, 'v_sit_anim':v_sit_anim, 'stop': true})
			get_node("/root/Tavern").join_table(current_table_id)
	elif 'wave' in anim_name:
		if npc and animate.current_animation != "npc_idle_down":
			default_npc_animation()
			use_npc_texture('idle', npc_type)
			rpc_unreliable("update_npc", {"npc_type": npc_type, "target": target, "animation": npc_type.default_animation, "texture": npc_type.texture_default})
	elif animate.get_current_animation_position() == 0:
	# Else the animation is finishing backwards and player is standing up
		if h_sit_anim == 'Left':
			animate.current_animation = 'idle_right'
		else:
			animate.current_animation = 'idle_left'
		current_table_id = null
		sitting = false
		busy = false
		get_node("../Table_00"+str(stool_dict.table)+"/Stool_00"+str(stool_dict.stool)).z_index = 0
		
func _on_Timer_timeout():
	if v_sit_anim == 'back':
		get_node("../Table_00"+str(stool_dict.table)+"/Stool_00"+str(stool_dict.stool)).z_index = 0
		
### Chatting ###

sync func receive_tavern_chat(msg: String, c_name: String, id=null, length=null) -> void:
	if id == null:
		get_parent().get_node(c_name).overhead_chat(msg, c_name, length)
	else:
		get_parent().get_node(str(id)).overhead_chat(msg, c_name, length)

func bubble_grow(char_count: float) -> void:
	# Each line of 18 characters is 15 pixels in size
	# for every 18 characters grow 15 in size.y and -15 in pos.y
	print("Char count:"+ str(char_count))
	if char_count <= 10:
		$ChatBubble.rect_size.x = char_count * 10
		$ChatBubble.rect_position.x = char_count * -5
	if char_count >= 18:
		var num_of_lines = float(char_count) / 18.0
		print(num_of_lines)
		num_of_lines = ceil(num_of_lines)
		print(num_of_lines)
		$ChatBubble.rect_size.y = $ChatBubble.rect_size.y * num_of_lines
		$ChatBubble.rect_position.y -= 15 * num_of_lines

func bubble_reset() -> void:
	$ChatBubble.rect_position.x = -50
	$ChatBubble.rect_size.x = 100
	$ChatBubble.rect_size.y = 15
	$ChatBubble.rect_position.y = -70

func overhead_chat(msg: String, c_name: String, length) -> void:
	# Tavern chat bubble
	var char_count
	if length == null:
		char_count = msg.length()
	else:
		char_count = length
	bubble_grow(char_count)
	$ChatBubble.bbcode_text = ""
	$ChatBubble.hint_tooltip = msg
	if msg.length() > 0:
		var t_msg = "["+c_name+"]: " + msg
		if npc:
			t_msg = "["+npc_type.name+"]: " + msg
		get_node("/root/Tavern/CanvasLayer/TavernChatBox").bbcode_text += t_msg
		get_node("/root/Tavern/CanvasLayer/TavernChatBox").bbcode_text += "\n"
	#if msg.length() < 18:
	msg = "[center]"+msg+"[/center]"
	$ChatBubble.bbcode_text = msg
	$ChatBubble/ChatTimer.start(5)
	$ChatBubble.visible = true

func _on_ChatTimer_timeout():
	#$ChatBubble.rect_size.y = $ChatBubble.rect_size.y / 2
	#$ChatBubble.rect_position.y = $ChatBubble.rect_position.y + 100
	$ChatBubble.clear()
	$ChatBubble.visible = false
	bubble_reset()		
		
## NPC Functions ##

remote func update_npc(npc_state: Dictionary) -> void:
	get_parent().get_node(npc_state.npc_type.name).animate.current_animation = npc_state.animation
	get_parent().get_node(npc_state.npc_type.name).use_npc_texture(npc_state.texture, npc_state.npc_type)

func npc_init(_npc_type: Dictionary) -> void:
	npc_type = _npc_type
	
func set_default_position(pos: Vector2) -> void:
	position = pos

func default_npc_animation() -> void:
	animate.current_animation = npc_type.default_animation
	use_npc_texture(npc_type.texture_default, npc_type)

func wave() -> void:
	use_npc_texture("wave", npc_type)
	animate.current_animation = "npc_wave_down"
	rpc_unreliable("update_npc", {"npc_type": npc_type, "target": target, "animation": animate.current_animation, "texture": "wave"})

func move_npc(_target: Vector2) -> void:
	target = _target
	
func use_npc_texture(animation: String, _npc_type: Dictionary) -> void:
	# called to set the proper texture and frames when animation changes
	if animation == 'idle':
		$Body.set_texture(load("res://Assets/NPCs/"+_npc_type.name+"_"+_npc_type.style+".png"))
		$Body.vframes = 1
		$Body.hframes = 4
	elif animation == 'wave':
		$Body.set_texture(load("res://Assets/NPCs/"+_npc_type.name+"_"+animation.capitalize()+"_"+_npc_type.style+".png"))
		$Body.vframes = 1
		$Body.hframes = 9
