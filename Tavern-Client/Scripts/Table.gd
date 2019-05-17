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

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func assign(_table_id):
	table_id = _table_id

func _on_ChatInput_text_entered(new_text):
	if command_time and command_param_start != null:
		command_params = new_text.substr(command_param_start, len(new_text)-1)
		slash_commands(new_text)
	else:
		send_message(new_text)

func _on_ChatInput_text_changed(new_text):
	if chat_input.text.substr(0,1) == "/":
		command_time = true
	else:
		command_time = false
	if command_time and new_text.substr(len(new_text)-1, len(new_text)-1) == " " and command_param_start == null:
		command_param_start = len(chat_input.text)
		
func slash_commands(text):
	var command = text.split(" ")[0].substr(1, len(text)-1)
	if chat_commands.has(command):
		call(command)
		
func send_message(msg):
	chat_input.text = ""
	rpc("receive_message", character_name, msg)

sync func receive_message(c_name, msg):
	if msg.length() > 0:
		chat_display.text += c_name + ": " + msg + "\n"

sync func whisper():
	var params = command_params.split(" ")
	var recipient = params[0]
	params.remove(0)
	var message = params.join(" ")
	print(message)
	
	## First word in params is the whisperee
	### search patron list
	#### Rest of params after whisperee is the message, maybe change the text color to indicate this
	
## sync func whisper():
	# var msg = chat_input.text
	# chat_input.text = ""
	## selected_character_to_whisper_to, assign this variable with a slash command
	# rpc_id(get_tree().get_network_unique_id(), "receive_message", character_name, msg)
	### get_tree().get_rpc_sender_id # Check this against which id is sent in the function?
	### If whoever sent this call doesn't match the id in the function they see the whisper action of both characters
		### Now also relizing I need to send the receipent of the whispers name in the call as well for this ^
		# rpc_id(id, "receive_whisper", character_name, 
	
## sync func receive_whisper(id, c_name, r_name, msg):
	#if msg.length() > 0:
	#	chat_display.text += c_name + ": " + msg + "\n"
	

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

func _on_PatronList_item_selected(index):
	## TODO: May want to change this logic to just call the whisper function and set params manually
	## Currently does not work
	chat_input.text = ""
	var command = "/whisper {name} ".format({"name": $PatronList.get_item_text(index)})
	chat_input.text = command
	chat_input.grab_focus()
	chat_input.caret_position = len(command)


