extends Node2D

export(PackedScene) var table
export(PackedScene) var player
export(PackedScene) var board


onready var entrance = $Entrance
onready var board_button = $YSort/Board/BoardButton
onready var chat_input = $CanvasLayer/ChatEnter
onready var board_scene = $BoardScene

var character_name = null
var player_info = {}
var tavern_menu = preload("res://Scenes/TavernMenu.tscn")
var chat_input_in_use = false

## NPCs ##
var barmaid
###
var stool_count = {
	1: { # table_id
		1: null, # stool number
		2: null,
		3: null,
		4: null,
		5: null,
		6: null
	},
	2: { # table_id
		1: null, # stool number
		2: null,
		3: null,
		4: null,
		5: null,
		6: null
	},
	3: { # table_id
		1: null, # stool number: patron.name
		2: null,
		3: null,
		4: null,
		5: null,
		6: null
	}
}

func _ready():
	get_tree().set_auto_accept_quit(false)
	get_tree().connect("connected_to_server", self, "entered_tavern")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	if g.player_data.tavern.ip != null and g.player_data.tavern.port != null:
		barmaid = player.instance()
		barmaid.set_npc(true)
		barmaid.npc_init({'name': 'Barmaid', 'style': '001', 'default_animation': 'npc_idle_down', 'texture_default': 'idle'})
		barmaid.set_name(barmaid.npc_type.name)
		barmaid.set_default_position($NPC_Barmaid.position)
		$YSort.add_child(barmaid)
		set_board_texture(g.player_data.tavern.post_number)
		character_name = g.player_data.character.name
		create_table_scenes()
		enter_tavern(g.player_data.tavern.ip, g.player_data.tavern.port)
		
func _process(delta):
	if chat_input.has_focus():
		chat_input.rect_position.y = g.get_top_of_keyboard_pos() - chat_input.get_size().y
		
func _notification(notif):
    if notif == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
        _on_Back_pressed()
    if notif == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        _on_Back_pressed()

func _on_Back_pressed():
	if chat_input.visible == true:
		chat_input.clear()
		chat_input.visible = false
		
	for t in get_tree().get_nodes_in_group("tables"):
		if t.visible == true:
			t.hide()
			leaving_table(t.table_id, get_tree().get_network_unique_id())
			return

	if board_scene.visible:
		get_node("/root/Tavern/YSort/"+str(get_tree().get_network_unique_id())).busy = false
		if get_node_or_null("BoardScene/Post") != null:
			get_node("BoardScene/Post").queue_free()
			return
		else:
			board_scene.hide()
			update_board_texture()
			return
		
	$CanvasLayer/AcceptDialog.popup_centered()
	
func _on_AcceptDialog_confirmed():
	leave_tavern()
	
func user_exited(id):
	player_info.erase(id) # Erase player from info
	for t in get_tree().get_nodes_in_group("tables"):
		print(t)
		print(stool_count)
		leaving_table(t.table_id, id)
		print(stool_count)

sync func remove_player(id):
	get_node("YSort/"+str(id)).queue_free()
	
func enter_tavern(ip, port):
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, port)
	get_tree().set_network_peer(host)

func entered_tavern():
	rpc("register_player", get_tree().get_network_unique_id(), g.player_data)
	rpc_id(0, "register_tables")
	barmaid.wave()	
	if is_network_master():
		get_node("YSort/Barmaid").rpc_unreliable("update_npc", {"target": get_node("YSort/Barmaid").position, "animation": "npc_wave_down", "texture": "wave"})
	
### Network Player Registration ###

remote func register_player(id, info):
	## Register players
	player_info[id] = info
	if get_tree().is_network_server():
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])
	rpc("configure_player")
	
remote func register_tables(tables=null):
	for t in get_tree().get_nodes_in_group("tables"):
		for tb in tables:
			if tb.id == t.get_table_id():
				t.set_table_patrons(tb.patrons)

remote func configure_player():
	# Load other characters
	for p in player_info:
		if not $YSort.get_node_or_null(str(p)):
			var new_player = player.instance()
			if player_info[p].position == null:
				new_player.position = entrance.position
			else:
				new_player.position = player_info[p].position
			new_player.init(player_info[p].character.gender, player_info[p].character.style, player_info[p].animation)
			new_player.set_name(str(p))
			new_player.set_network_master(p)
			$YSort.add_child(new_player)
			
func change_scene_manually():
    # Remove tavern
	var root = get_tree().get_root()
	queue_free()
	
	# Add the proper menu
	var tavern_menu_resource = load("res://Scenes/MainMenu.tscn")
	var tavern_menu = tavern_menu_resource.instance()
	tavern_menu.get_node('TavernSign_Logo').visible = false
	tavern_menu.get_node('TavernMenu').visible = true
	root.add_child(tavern_menu)
	
func leave_tavern():
	get_tree().set_network_peer(null)
	change_scene_manually()
	## Let tavern API know the character left the tavern

func _server_disconnected():
	leave_tavern()
	
### Tables ###
sync func update_stool_count(_stool_count):
	stool_count = _stool_count

func get_min(arr):
	arr.sort()
	return arr[0]
	
func find_closest_stool(table_id, patron):
	# dictionary of available stools and their positions
	var stool_pos_dict = {}
	#loop through all stools for availablity
	for stool in stool_count[table_id]:
		var stool_node = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool))
		stool_count[table_id][stool]
		if stool_count[table_id][stool] == null:
		# if stool is available set the stool number as key and distance from patron as value
			stool_pos_dict[(stool_node.get_global_position() - patron.position).length()] = stool
	#if len(stool_pos_dict.keys()) < 0:
	if stool_pos_dict.keys().size() > 0:
		return stool_pos_dict[get_min(stool_pos_dict.keys())]
	return 0
	
func _on_Table_button_up(table_id):
	#for stool in stool_count[table_id]:
	var stool_pos
	var patron = get_node("YSort/"+str(get_tree().get_network_unique_id()))
	if patron.is_busy():
		# If the player is sitting down they can't keep sitting to new stools
		return
	var stool = find_closest_stool(table_id, patron)
	if stool == 0:
		# If there are no closest stools then the player can't click to join
		return
	var stool_node = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool))
	if stool >= 4:
		# if the stool is on the bottom row use back animation
		patron.v_sit_anim = 'front'
	else:
		# Else it's the top row and use the front animation
		patron.v_sit_anim = 'back'
	# if stool is empty 
	if patron.position.x > stool_node.get_global_position().x:
		patron.h_sit_anim = 'Right'
		# if the player is to the right of the stool use right animation and stool position
		if stool == 6 or stool == 3:
			stool_pos = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool)+"/R_P").get_global_position()
		else:
			stool_pos = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool+1)+"/L_P").get_global_position()
	else:
		patron.h_sit_anim = 'Left'
		# player is to the left of the stool
		stool_pos = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool)+"/L_P").get_global_position()
	stool_count[table_id][stool] = patron.name
	patron.sit_down(stool_pos, stool, table_id)
	rpc("update_stool_count", stool_count)
	
func join_table(table_id):
	for t in get_tree().get_nodes_in_group("tables"):
		if t.table_id == table_id:
			t.show()

func leaving_table(table_id, id):
	for stool in stool_count[table_id]:
		#var stool_node = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool))
		if stool_count[table_id][stool] != null:
			if stool_count[table_id][stool] == str(id):
				get_node_or_null("YSort/"+stool_count[table_id][stool]).stand_up(stool, table_id)
				stool_count[table_id][stool] = null
				rpc("update_stool_count", stool_count)
				break

func create_table_scenes():
	for t in range(1, 4):
		# instance packed scene
		var new_table = table.instance()
		new_table.assign(t)
		new_table.set_name("Table" + str(t))
		new_table.hide()
		add_child(new_table)
		new_table.add_to_group("tables")

sync func table_join_view(show, id, table_id):
	## TODO: Before release change id to int before it gets in here 
	if get_tree().get_network_unique_id() == id:
		if show:
			get_node('YSort/Table_'+table_id+'/Join').visible = true
			get_node('YSort/Table_'+table_id+'/Join').disabled = false
		else:
			get_node('YSort/Table_'+table_id+'/Join').visible = false
			get_node('YSort/Table_'+table_id+'/Join').disabled = true

func table_full(id):
	# Checks if a table is full of patrons
	for stool in stool_count[id]:
		if stool_count[id][stool] == null:
			return false
	return true
	
func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape, table_id):
	## TODO: change table_id to int of table number instead of leading 00s
	if area != null and not table_full(int(table_id[2])):
		print(area)
		# If there's a player and the table is not full, then show join table and enable the button
		rpc("table_join_view", true, int(area.get_parent().name), table_id)
	else:
		rpc("table_join_view", false, int(area.get_parent().name), table_id)
	
func _on_Area2D_area_shape_exited(area_id, area, area_shape, self_shape, table_id):
	if area != null:
		rpc("table_join_view", false, int(area.get_parent().name), table_id)

### Bulletin Board ###
		
func _on_Board_button_up():
	board_scene.visible = true
	
sync func board_view(show, id):
	if get_tree().get_network_unique_id() == int(id):
		if show:
			board_button.visible = true
			board_button.disabled = false
		else:
			board_button.visible = false
			board_button.disabled = true

func _on_BoardArea_area_shape_entered(area_id, area, area_shape, self_shape):
	if area != null:
		rpc("board_view", true, area.get_parent().name)

func _on_BoardArea_area_shape_exited(area_id, area, area_shape, self_shape):
	if area != null:
		rpc("board_view", false, area.get_parent().name)

func update_board_texture():
	g.make_get_request($YSort/Board/PostCheck, 'tavern/' + g.player_data.tavern.id +'/board')

func _on_PostCheck_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var post_number = len(json.result.data)
	set_board_texture(post_number)
	
func set_board_texture(post_number):
	if post_number == 0:
		$YSort/Board.set_texture(load("res://Assets/furniture/BulletinBoardA_001.png"))
	elif post_number < 6:
		$YSort/Board.set_texture(load("res://Assets/furniture/BulletinBoardA_002.png"))
	else:
		$YSort/Board.set_texture(load("res://Assets/furniture/BulletinBoardA_003.png"))

### Leaving Tavern ###

sync func leave_button_view(show, id):
	if show:
		if id == get_tree().get_network_unique_id():
			$Exit/LeaveButton.visible = true
			$Exit/LeaveButton.disabled = false
	else:
		if id == get_tree().get_network_unique_id():
			$Exit/LeaveButton.visible = false
			$Exit/LeaveButton.disabled = true
	
func _on_Exit_body_entered(body):
	rpc("leave_button_view", true, int(body.name))

func _on_Exit_body_exited(body):
	rpc("leave_button_view", false, int(body.name))

func _on_LeaveButton_button_up():
	leave_tavern()
	
	
### Tavern Chat ###

func chat_enter_view():
	chat_input.visible = true
	chat_input.grab_focus()
	chat_input.rect_position.y = g.get_top_of_keyboard_pos() - chat_input.get_size().y
	chat_input_in_use = true
			
func _on_Chat_button_up():
	chat_enter_view()
	
var command_time = false
var command_param_start = null
var chat_commands = ['yell']

func slash_commands(text, params):
	var command = text.split(" ")[0].substr(1, len(text)-1)
	if chat_commands.has(command):
		call(command, params)

func _on_ChatEnter_text_entered(new_text):
	if command_time and command_param_start != null:
		var command_params = new_text.substr(command_param_start, len(new_text)-1)
		command_params = command_params.split(" ")
		command_param_start = null # Resets command param
		slash_commands(new_text, command_params)
	else:
		get_node(str("YSort/"+str(get_tree().get_network_unique_id()))).rpc("receive_tavern_chat", new_text, get_tree().get_network_unique_id())
	chat_input.clear()
	chat_input.visible = false
	chat_input_in_use = false
		
func _on_ChatEnter_text_changed(new_text):
	if chat_input.text.substr(0,1) == "/":
		command_time = true
	else:
		command_time = false
	if command_time and new_text.substr(1, len(new_text)) in chat_commands:
		command_param_start = len(chat_input.text) + 1

### Tavern Chat Commands ###

func yell(params):
	var msg = params.join(" ")
	var tav_msg = '[color=#ff4f6d][b]'+msg.to_upper()+'[/b][/color]' ## Increase font or change color to Red maybe?
	var table_msg = "yells, "+"\""+msg+"\""
	get_node("YSort/"+str(get_tree().get_network_unique_id())).rpc("receive_tavern_chat", tav_msg, get_tree().get_network_unique_id())
	chat_input.clear()
	rpc("chat_enter_view", false, get_tree().get_network_unique_id())
	for t in get_tree().get_nodes_in_group("tables"):
		t.rpc("receive_broadcast_message", character_name, table_msg, 0)


### Not currently being implemented - on hold ###
sync func t_chat(msg, table_id):
	var table_chat = get_node("Table_00"+str(table_id)+"/CanvasLayer/TableChat")
	table_chat.bbcode_text = ""
	table_chat.hint_tooltip = msg
	msg = "[center]"+msg+"[/center]"
	table_chat.bbcode_text = msg
	table_chat.get_child().start(5)
	
func _on_TableChatTimer_timeout():
	get_parent().clear()