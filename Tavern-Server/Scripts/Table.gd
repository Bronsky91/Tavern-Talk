extends Node2D

onready var chat_display = $ChatDisplay
onready var chat_input = $ChatInput

var character_name = global.player_data.character.name
var table_id = null
var current_patrons = []
var chat_commands = ['whisper']
var command_time = false
var command_param_start = null
var command_params = null

class SortPatronNames:
	static func sort(a, b):
		if a.name < b.name:
			return true
		return false

func assign(_table_id):
	table_id = _table_id

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")

sync func receive_message(c_name, msg):
	if msg.length() > 0:
		chat_display.text += c_name + ": " + msg + "\n"
		
sync func whisper():
	var params = command_params.split(" ")
	var recipient = params[0]
	params.remove(0)
	var msg = params.join(" ")
	var r_id = null
	for patron in current_patrons:
		if patron.name.to_lower() == recipient.to_lower():
			r_id = patron.id
	if r_id != null:
		## Send whisper
		chat_input.text = ""
		rpc("receive_whisper", get_tree().get_network_unique_id(), r_id, character_name, recipient.capitalize(), msg)
	else:
		## TODO: Error message for not finding patron
		print("patron not found")

sync func receive_whisper(c_id, r_id, c_name, r_name, msg):
	if msg.length() > 0 and get_tree().get_network_unique_id() == r_id or get_tree().get_network_unique_id() == c_id:
		chat_display.text += c_name + ": " + msg + "\n"
	else:
		chat_display.text += c_name + " whispers to " + r_name + "\n"
		
sync func receive_action_message(c_name, msg):
		chat_display.text += c_name + " " + msg + "\n"

sync func set_current_patrons(id, patron_name):
	var patron = {'id': id, 'name': patron_name}
	current_patrons.append(patron)
	current_patrons.sort_custom(SortPatronNames, "sort")
	$PatronList.add_item(patron.name)
	$PatronList.sort_items_by_text()

sync func remove_patron(id):
	var patron_that_left
	for i in current_patrons.size():
		print(current_patrons)
		if current_patrons[i].id == id:
			current_patrons.remove(i)
			patron_that_left = i
			break
	$PatronList.remove_item(patron_that_left)
	
func _on_Leave_button_up():
	.hide()
