extends Node2D

onready var chat_display = $ChatDisplay
onready var chat_input = $ChatInput

var character_name = global.player_data.character.name
var table_id = null
var current_patrons = []

class SortPatronNames:
	static func sort(a, b):
		if a.name < b.name:
			return true
		return false

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
	slash_commands(msg)
	chat_input.text = ""
	rpc("receive_message", character_name, msg)

sync func receive_message(c_name, msg):
	if msg.length() > 0:
		chat_display.text += c_name + ": " + msg + "\n"

## sync send_private_message(id):
	# var msg = chat_input.text
	# chat_input.text = ""
	## selected_character_to_whisper_to, assign this variable with a slash command
	# rpc_id(get_tree().get_network_unique_id(), "receive_message", character_name, msg)
	### get_tree().get_rpc_sender_id # Check this against which id is sent in the function?
	### If whoever sent this call doesn't match the id in the function they see the whisper action of both characters
		### Now also relizing I need to send the receipent of the whispers name in the call as well for this ^
		# rpc_id(id, "receive_private_message", character_name, 
	
## sync receive_private_message(id, c_name, r_name, msg):
	# var msg = chat_input.text
	# chat_input.text = ""
	
func slash_commands(text):
	## Like Known commands
	print(text.substr(0,1))
	if text.substr(0,1) == "/":
		print(text)
		
sync func set_current_patrons(id, patron_name):
	var patron = {'id': id, 'name': patron_name}
	current_patrons.append(patron)
	current_patrons.sort_custom(SortPatronNames, "sort")
	$PatronList.add_item(patron.name)
	$PatronList.sort_items_by_text()
	
sync func remove_patron(id):
	var patron_that_left
	for i in current_patrons.size():
		if current_patrons[i].id == id:
			current_patrons.remove(i)
			patron_that_left = i
			break
	$PatronList.remove_item(patron_that_left)

sync func receive_action_message(c_name, msg):
	chat_display.text += c_name + " " + msg + "\n"

func _on_Leave_button_up():
	.hide()
	
func _on_Table_visibility_changed():
	if visible == true:
		rpc("receive_action_message", character_name, "sits at the table")
		rpc("set_current_patrons", get_tree().get_network_unique_id(), character_name)
	else:
		rpc("receive_action_message", character_name, "leaves the table")
		rpc("remove_patron", get_tree().get_network_unique_id())
