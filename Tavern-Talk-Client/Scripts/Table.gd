extends Node2D

onready var chat_display = $ChatDisplay
onready var chat_input = $ChatInput

var character_name = global.player_data.character.name
var table_id = null

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func assign(_table_id):
	table_id = _table_id

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
	    	send_message()

func send_message():
	var msg = chat_input.text
	chat_input.text = ""
	rpc("receive_message", character_name, msg)

sync func receive_message(c_name, msg):
	if msg.length() > 0:
		chat_display.text += c_name + ": " + msg + "\n"
		
sync func receive_action_message(c_name, msg):
	chat_display.text += c_name + " " + msg + "\n"

func _on_Leave_button_up():
	.hide()

func _on_Table_visibility_changed():
	if visible == true:
		rpc("receive_action_message", character_name, "sits at the table")
	else:
		rpc("receive_action_message", character_name, "leaves the table")
