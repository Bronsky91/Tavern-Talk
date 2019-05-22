extends Node2D

onready var chat_display = $ChatDisplay
onready var chat_input = $ChatInput
onready var cmd = get_node("Commands")

var character_name = global.player_data.character.name
var table_id = null
var current_patrons = []
var command_time = false
var command_param_start = null

var chat_commands = ['whisper', 'throw', 'e', 'eb', 'yell']

class SortPatronNames:
	static func sort(a, b):
		if a.name < b.name:
			return true
		return false

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func get_current_patrons():
	return current_patrons

func new_line():
	chat_display.bbcode_text += "\n"

func assign(_table_id):
	table_id = _table_id

func _on_ChatInput_text_entered(new_text):
	if command_time and command_param_start != null:
		print(new_text)
		var command_params = new_text.substr(command_param_start, len(new_text)-1)
		print(command_params)
		command_params = command_params.split(" ")
		command_param_start = null # Resets command param
		slash_commands(new_text, command_params)
	else:
		send_message(new_text)

func _on_ChatInput_text_changed(new_text):
	if chat_input.text.substr(0,1) == "/":
		command_time = true
	else:
		command_time = false
	if command_time and new_text.substr(len(new_text)-1, len(new_text)-1) == " " and command_param_start == null:
		command_param_start = len(chat_input.text)
		
func slash_commands(text, params):
	var command = text.split(" ")[0].substr(1, len(text)-1)
	if chat_commands.has(command):
		cmd.call(command, params)
		
func send_message(msg):
	chat_input.text = ""
	rpc("receive_message", character_name, msg)
	
func send_broadcast(msg):
	chat_input.text = ""
	for t in get_tree().get_nodes_in_group("tables"):
		t.rpc("receive_broadcast_message", character_name, msg, table_id)

sync func receive_broadcast_message(c_name, msg, t_id):
	if msg.length() > 0:
		if table_id == t_id:
			var new_line = c_name +" "+ msg
			chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
			new_line()
		else:
			var new_line = "A patron from another table "+ msg
			chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
			new_line()

sync func receive_message(c_name, msg):
	if msg.length() > 0:
		var new_line = c_name + ": " + msg
		chat_display.bbcode_text += new_line
		new_line()
	
sync func receive_whisper(c_id, r_id, c_name, r_name, msg):
	if msg.length() > 0 and get_tree().get_network_unique_id() == r_id or get_tree().get_network_unique_id() == c_id:
		var new_line = c_name + ": " + msg
		new_line = '[color=#cc379f]'+new_line+'[/color]'
		chat_display.bbcode_text += new_line
		new_line()
	else:
		chat_display.bbcode_text += c_name + " whispers to " + r_name + "\n"

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

func find_random_patron():
	var random_patron = current_patrons[randi()%len(current_patrons)]
	if len(current_patrons) == 1:
		return random_patron
	if random_patron.name == character_name:
		find_random_patron()
	else:
		return random_patron
	
func send_action_message(msg):
	chat_input.text = ""
	rpc("receive_action_message", character_name, msg)
	
sync func receive_action_message(c_name, msg):
	var new_line = c_name + " " + msg
	chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
	new_line()

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
	pass
	## TODO: May want to change this logic to just call the whisper function and set params manually
	## Currently does not work
	#chat_input.text = ""
	#var command = "/whisper {name} ".format({"name": $PatronList.get_item_text(index)})
	#chat_input.text = command
	#chat_input.grab_focus()
	#chat_input.caret_position = len(command)