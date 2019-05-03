extends Node2D

onready var chat_display = $ChatDisplay
onready var chat_input = $ChatInput

var character_name = global.player_data.character.name
var table_id = null

func assign(_table_id):
	table_id = _table_id

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")

sync func receive_message(c_name, msg):
	if msg.length() > 0:
		chat_display.text += c_name + ": " + msg + "\n"

sync func receive_action_message(c_name, msg):
		chat_display.text += c_name + " " + msg + "\n"
	
func _on_Leave_button_up():
	.hide()
