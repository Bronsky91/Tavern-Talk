extends Node2D

class_name Table

export(PackedScene) var armwrestle_node: PackedScene

onready var chat_display: RichTextLabel = $ChatDisplay
onready var chat_input: LineEdit = $ChatInput
onready var cmd = get_node("Commands")

var character_name: String = g.player_data.character.name
var table_id = null
var current_patrons: Array
var command_time: bool = false
var command_param_start = null

var chat_commands: Array = ['help', 'w', 'throw', 'e', 'eb', 'yell', 'armwrestle', 'roll', 'cointoss']

class SortPatronNames:
	static func sort(a, b):
		if a.name < b.name:
			return true
		return false

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	
func _process(delta):
	raise_text_edit(chat_input)
		
func raise_text_edit(input: LineEdit) -> void:
	if input.has_focus():
		input.rect_position.y = g.get_top_of_keyboard_pos() - input.get_size().y
		chat_display.rect_size.y = input.rect_position.y
	else:
		chat_input.rect_position.y = get_viewport().size.y - 30
		chat_display.rect_size.y = get_viewport().size.y - 40

func user_exited(id: int) -> void:
	rpc("remove_patron", id)
	
func assign(_table_id: int) -> void:
	## Called upon creation of node
	table_id = _table_id
	
func get_current_patrons() -> Array:
	## Helper for other nodes
	return current_patrons
	
func get_table_id() -> int:
	return table_id

func set_table_patrons(patron_list: Array) -> void:
	for p in patron_list:
		set_patron(p.id, p.name, p.stats)
		
### Text input and commands ###

func new_line() -> void:
	chat_display.bbcode_text += "\n"

func _on_ChatInput_text_entered(new_text: String) -> void:
	if command_time and command_param_start != null:
		var command_params_string: String = new_text.substr(command_param_start, len(new_text)-1)
		var command_params_array: PoolStringArray = command_params_string.split(" ")
		command_param_start = null # Resets command param
		slash_commands(new_text, command_params_array)
	else:
		send_message(new_text)

func _on_ChatInput_text_changed(new_text: String) -> void:
	if chat_input.text.substr(0,1) == "/":
		command_time = true
	else:
		command_time = false
	if command_time and new_text.substr(1, len(new_text)) in chat_commands:
		command_param_start = len(chat_input.text) + 1
		
func slash_commands(text: String, params: PoolStringArray) -> void:
	var command: String = text.split(" ")[0].substr(1, len(text)-1)
	if chat_commands.has(command):
		cmd.call(command, params)

### Table Patrons ###

sync func set_patron(id: int, patron_name: String, stats: Dictionary) -> void:
	var patron: Dictionary = {'id': id, 'name': patron_name, 'stats': stats}
	current_patrons.append(patron)
	current_patrons.sort_custom(SortPatronNames, "sort")
	$PatronList.add_item(patron.name)
	$PatronList.sort_items_by_text()
	
sync func remove_patron(id: int) -> void:
	var patron_that_left: int
	for i in current_patrons.size():
		if current_patrons[i].id == id:
			current_patrons.remove(i)
			patron_that_left = i
			break
	if patron_that_left != null:
		$PatronList.remove_item(patron_that_left)

func find_random_patron() -> Dictionary:
	var random_patron = current_patrons[randi()%len(current_patrons)]
	if len(current_patrons) == 1:
		return random_patron
	if random_patron.name == character_name:
		find_random_patron()
	return random_patron
		
func find_patron_by_name(name: String) -> Dictionary:
	for patron in current_patrons:
		if patron.name.to_lower().findn(name.to_lower()) != -1:
			return patron
	return {'msg': 'no patron found'}
	
### Send and Receive Messages in Chat ###

func send_message(msg: String) -> void:
	chat_input.text = ""
	rpc("receive_message", character_name, msg)
	
func send_broadcast(msg: String) -> void:
	chat_input.text = ""
	for t in get_tree().get_nodes_in_group("tables"):
		t.rpc("receive_broadcast_message", character_name, msg, table_id)

func send_system_message(id: int, msg: String) -> void:
	chat_input.text = ""
	receive_system_message(msg)

sync func receive_broadcast_message(c_name: String, msg: String, t_id: int) -> void:
	if msg.length() > 0:
		#get_parent().rpc("t_chat", msg, t_id) # References Tavern.gd t_chat function, not being used yet
		if table_id == t_id:
			var new_line: String = c_name + " "+ msg
			chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
			new_line()
		elif t_id == 0:
			var new_line: String = "A patron in the tavern "+ msg
			chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
			new_line()
		else:
			var new_line = "A patron from another table "+ msg
			chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
			new_line()

sync func receive_message(c_name: String, msg: String) -> void:
	if msg.length() > 0:
		var new_line: String = "["+c_name+"]: " + msg
		if c_name == character_name:
			chat_display.bbcode_text += '[b]'+new_line+'[/b]'
		else:
			chat_display.bbcode_text += new_line
		new_line()

func receive_system_message(msg: String) -> void:
	if msg.length() > 0:
		var new_line: String = "[System]: " + msg
		chat_display.bbcode_text += '[color=#ffe700]'+new_line+'[/color]'
		new_line()
	
sync func receive_whisper(c_id: int, r_id: int, c_name: String, r_name: String, msg: String):
	if get_tree().get_network_unique_id() == r_id:
		var new_line: String = "["+c_name+"] whispers" + ": " + msg
		new_line = '[color=#cc379f]'+new_line+'[/color]'
		chat_display.bbcode_text += new_line
		new_line()
	if get_tree().get_network_unique_id() == c_id:
		var new_line: String = "To: ["+r_name+"]" + ": " + msg
		new_line = '[color=#cc379f]'+new_line+'[/color]'
		chat_display.bbcode_text += new_line
		new_line()
	else:
		for patron in current_patrons:
			if c_id != patron.id and r_id != patron.id and patron.id == get_tree().get_network_unique_id():
				if patron.stats.wis > 11:
				# if a patron at the table has the wisdom they can hear random words of the whisper based on stat mod
					var broken_msg = msg.split(" ")
					chat_display.bbcode_text +='[color=#ff893f]'+'[i]'+ c_name + " whispers "+ random_sneak(broken_msg ,g.calc_stat_mod(patron.stats.wis)) +" to " + r_name +'[/i]'+'[/color]'
					new_line()
				else:
					chat_display.bbcode_text +='[color=#ff893f]'+'[i]'+ c_name + " whispers to " + r_name +'[/i]'+'[/color]'
					new_line()

func random_sneak(b_m: PoolStringArray, max_sneak: int) -> String:
	if max_sneak > len(b_m):
	# if your max_sneak is greater than the message length just return the whole message
		return b_m.join(" ")
	var sneak_msg = ""
	var sneak_words = []
	while len(sneak_words) < max_sneak:
		var rand_word = randi()%b_m.size()
		if sneak_words.find(rand_word) == -1:
			sneak_words.append(rand_word)
	sneak_words.sort()
	for sneak in sneak_words:
		sneak_msg = sneak_msg + "..."+b_m[sneak]+" "
	return sneak_msg
	
func send_action_message(msg: String) -> void:
	chat_input.text = ""
	rpc("receive_action_message", character_name, msg)
	
sync func receive_action_message(c_name: String, msg: String) -> void:
	var new_line: String = c_name + " " + msg
	chat_display.bbcode_text += '[color=#ff893f]'+'[i]'+new_line+'[/i]'+'[/color]'
	new_line()

### Entering and Leaving Table ### 

func _on_Leave_button_up():
	.hide()
	get_parent().leaving_table(table_id, get_tree().get_network_unique_id())
	
func _on_Table_visibility_changed():
	if visible == true:
		get_node("/root/Tavern/YSort/"+str(get_tree().get_network_unique_id())).busy = true
		rpc("receive_action_message", character_name, "sits at the table")
		rpc("set_patron", get_tree().get_network_unique_id(), character_name, g.player_data.character.stats)
	elif visible == false:
		get_node("/root/Tavern/YSort/"+str(get_tree().get_network_unique_id())).busy = false
		rpc("receive_action_message", character_name, "leaves the table")
		rpc("remove_patron", get_tree().get_network_unique_id())

### Games ###

var players: Dictionary

func set_players(p: Array) -> void:
	players = {} # Clears any old players
	var i: int = 1
	for player in p:
		players[i] = player
		i += 1

remote func ask_for_aw(player1: Dictionary, player2: Dictionary) -> void:
	set_players([player1, player2])
	if character_name != players[1].name:
		$CanvasLayer/AcceptDialog.window_title = "Arm Wrestle!"
		$CanvasLayer/AcceptDialog.dialog_text = "Accept Arm Wrestle from "+players[1].name.capitalize()+"?"
		$CanvasLayer/AcceptDialog.popup_centered()

sync func armwrestle(player1: Dictionary, player2: Dictionary) -> void:
	var aw_node = armwrestle_node.instance()
	if character_name == player1.name or character_name == player2.name:
		aw_node.initiate(player1, player2)
	else:
		aw_node.spectator()
	add_child(aw_node)

remote func clear_chat() -> void:
	chat_input.text = ""
	
func _on_AcceptDialog_confirmed():
	rpc("armwrestle", players[1], [2])

func _on_AcceptDialog_popup_hide():
	#TODO: Display table system message that armwrestle was declined
	for player in players:
		send_system_message(player.id, "Arm wrestle has been declined, womp womp")
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

