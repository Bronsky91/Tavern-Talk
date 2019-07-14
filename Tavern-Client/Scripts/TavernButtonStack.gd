extends Button

onready var button_stack: AnimatedSprite = get_parent().get_node("ButtonStackAnimation")
onready var emote_button: Button = get_parent().get_node("ButtonStackAnimation/EmoteButton")
onready var inventory_button_rect: TextureRect = get_parent().get_node("ButtonStackAnimation/Inventory/TextureRect")
onready var chat_button: Button = get_parent().get_node("ButtonStackAnimation/Chat")

var stack_open: bool = false

#func _ready() -> void:
#	if button_stack.frame == 0:
#		for button in get_tree().get_nodes_in_group("stack_buttons"):
#			button.hide()
#			button.disabled = true

func _on_ButtonStackAnimation_frame_changed():
	## Transforms buttons in stack to follow animation and disable when showing/hiding stack
	for button in get_tree().get_nodes_in_group("stack_buttons"):
		if button_stack.animation == "Close" and button_stack.frame == 4:
			button.hide()
			button.disabled = true
		if button_stack.animation == "Open":
			if button_stack.frame > 1:
				button.show()
				button.disabled = false
			if button_stack.frame == 4:
				button.rect_position.x = -17
			button.rect_scale.x = 1
		if button_stack.frame < 4:
			button.rect_position.x = 0
			button.rect_scale.x = .5

func _on_ButtonStack_button_up():
	## Move button to line up with animation
	if self.rect_position.x == 329:
		## Opening
		button_stack.play("Open")
		self.rect_position.x = 292
	elif self.rect_position.x == 292:
		## Closing
		self.rect_position.x = 329
		button_stack.play("Close")
