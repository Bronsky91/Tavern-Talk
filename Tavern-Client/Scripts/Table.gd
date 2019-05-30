extends Node2D

export(PackedScene) var armwrestle_node

onready var chat_display = $ChatDisplay
onready var chat_input = $ChatInput
onready var cmd = get_node("Commands")

var character_name = global.player_data.character.name
var table_id = null
var current_patrons = []
var command_time = false
var command_param_start = null

var chat_commands = ['whisper', 'throw', 'e', 'eb', 'yell', 'armwrestle']

class SortPatronNames:
	static func sort(a, b):
		if a.name < b.name:
			return true
		return false

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	
func user_exited(id):
	rpc("receive_action_message", character_name, "leaves the table")
	rpc("remove_patron", id)
	
func assign(_table_id):
	## Called upon creation of node
	table_id = _table_id
	
func get_current_patrons():
	## Helper for other nodes
	return current_patrons
	
func get_table_id():
	return table_id

func set_table_patrons(patron_list):
	for p in patron_list:
		set_patron(p.id, p.name, p.stats)
		
### Text input and commands ###

func new_line():
	chat_display.bbcode_text += "\n"

func _on_ChatInput_text_entered(new_text):
	if command_time and command_param_start != null:
		var command_params = new_text.substr(command_param_start, len(new_text)-1)
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

### Table Patrons ###

sync func set_patron(id, patron_name, stats):
	var patron = {'id': id, 'name': patron_name, 'stats': stats}
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
		
func find_patron_by_name(name):
	for patron in current_patrons:
		if patron.name.to_lower() == name.to_lower():
			return patron
	
### Send and Receive Messages in Chat ###

func send_message(msg):
	chat_input.text = ""
	rpc("receive_message", character_name, msg)
	
func send_broadcast(msg):
	chat_input.text = ""
	for t in get_tree().get_nodes_in_group("tables"):
		t.rpc("receive_broadcast_message", character_name, msg, table_id)

sync func receive_broadcast_message(c_name, msg, t_id):
	if msg.length() > 0:
		#get_parent().rpc("t_chat", msg, t_id) # References Tavern.gd t_chat function, not being used yet
		if table_id == t_id:
			var new_line = "["+c_name+"]" +" "+ msg
			chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
			new_line()
		elif t_id == 0:
			var new_line = "A patron in the tavern "+ msg
			chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
			new_line()
		else:
			var new_line = "A patron from another table "+ msg
			chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
			new_line()

sync func receive_message(c_name, msg):
	if msg.length() > 0:
		var new_line = "["+c_name+"]" + ": " + msg
		if c_name == character_name:
			chat_display.bbcode_text += '[b]'+new_line+'[/b]'
		else:
			chat_display.bbcode_text += new_line
		new_line()
	
sync func receive_whisper(c_id, r_id, c_name, r_name, msg):
	if msg.length() > 0 and get_tree().get_network_unique_id() == r_id:
		var new_line = "["+c_name+"] whispers" + ": " + msg
		new_line = '[color=#cc379f]'+new_line+'[/color]'
		chat_display.bbcode_text += new_line
		new_line()
	if get_tree().get_network_unique_id() == c_id:
		var new_line = "To: ["+r_name+"]" + ": " + msg
		new_line = '[color=#cc379f]'+new_line+'[/color]'
		chat_display.bbcode_text += new_line
		new_line()
	else:
		chat_display.bbcode_text +='[color=#ff893f]'+'[i]'+ c_name + " whispers to " + r_name +'[/i]'+'[/color]'
		new_line()

func send_action_message(msg):
	chat_input.text = ""
	rpc("receive_action_message", character_name, msg)
	
sync func receive_action_message(c_name, msg):
	var new_line = c_name + " " + msg
	chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
	new_line()

### Entering and Leaving Table ### 

func _on_Leave_button_up():
	.hide()
	
func _on_Table_visibility_changed():
	if visible == true:
		get_node("/root/Tavern/YSort/"+str(get_tree().get_network_unique_id())).busy = true
		rpc("receive_action_message", character_name, "sits at the table")
		rpc("set_patron", get_tree().get_network_unique_id(), character_name, global.player_data.character.stats)
	else:
		get_node("/root/Tavern/YSort/"+str(get_tree().get_network_unique_id())).busy = false
		rpc("receive_action_message", character_name, "leaves the table")
		rpc("remove_patron", get_tree().get_network_unique_id())

### Games ###

var players = {}

func set_players(p):
	players = {} # Clears any old players
	var i = 1
	for player in p:
		players[i] = player
		i += 1

remote func ask_for_aw(player1, player2):
	set_players([player1, player2])
	if character_name != players[1].name:
		$CanvasLayer/AcceptDialog.window_title = "Arm Wrestle!"
		$CanvasLayer/AcceptDialog.dialog_text = "Accept Arm Wrestle from "+players[1].name.capitalize()+"?"
		$CanvasLayer/AcceptDialog.popup_centered()

sync func armwrestle(player1, player2):
	var aw_node = armwrestle_node.instance()
	if character_name == player1.name or character_name == player2.name:
		aw_node.initiate(player1, player2)
	else:
		aw_node.spectator()
	add_child(aw_node)

remote func clear_chat():
	chat_input.text = ""
	
func _on_AcceptDialog_confirmed():
	rpc("armwrestle", players[1], players[2])

func _on_AcceptDialog_popup_hide():
	#TODO: Display table system message that armwrestle was declined
	rpc_id(players[1].id, "clear_chat")


### Patron List at Table ###

#func _on_PatronList_item_selected(index):
#	pass
	## TODO: May want to change this logic to just call the whisper function and set params manually
	## Currently does not work
	#chat_input.text = ""
	#var command = "/whisper {name} ".format({"name": $PatronList.get_item_text(index)})
	#chat_input.text = command
	#chat_input.grab_focus()
	#chat_input.caret_position = len(command)

