extends Node2D

export(PackedScene) var table: PackedScene
export(PackedScene) var player: PackedScene
export(PackedScene) var board: PackedScene
export(PackedScene) var game_table: PackedScene

onready var entrance: Position2D = $Entrance
onready var board_button: Button = $YSort/Board/BoardButton
onready var chat_input: LineEdit = $CanvasLayer/ChatEnter
onready var chat_display: RichTextLabel = $CanvasLayer/TavernChatBox
onready var board_scene: Board = $BoardScene

var TABLE_COUNT: int = 4
var GAME_TABLES: Array = [4]

var character_name = null
var player_info: Dictionary
var tavern_menu: PackedScene = preload("res://Scenes/TavernMenu.tscn")
var overhead: bool = false

## NPCs ##
var barmaid: Patron
var bard: Patron
###    ###

var stool_count: Dictionary = {
	0: { # Table 0 == Bar
		1: null,
		2: null,
		3: null,
		4: null
	},
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
	},
	4: { # table_id
		1: null, # stool number: patron.name
		2: null
	}
}

func _ready():
	get_tree().set_auto_accept_quit(false)
	get_tree().connect("connected_to_server", self, "entered_tavern")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	if g.player_data.tavern.ip != null and g.player_data.tavern.port != null:
		barmaid = instance_npc({'name': 'Barmaid', 'style': '001', 'default_animation': 'npc_idle_down', 'texture_default': 'idle'}, $NPC_Barmaid.position)
		bard = instance_npc({'name': 'Bard', 'style': '001', 'default_animation': 'npc_play_down', 'texture_default': 'play'}, $NPC_Bard.position)
		set_board_texture(g.player_data.tavern.post_number)
		character_name = g.player_data.character.name
		create_table_scenes()
		enter_tavern(g.player_data.tavern.ip, g.player_data.tavern.port)

func instance_npc(npc_deets: Dictionary, npc_pos: Vector2) -> Patron:
	var npc: Patron = player.instance()
	npc.set_npc(true)
	npc.npc_init(npc_deets)
	npc.set_name(npc_deets.name)
	npc.set_default_position(npc_pos)
	$YSort.add_child(npc)
	return npc

func _process(delta):
	if chat_input.has_focus():
		chat_input.rect_position.y = g.get_top_of_keyboard_pos() - chat_input.get_size().y
		$CanvasLayer/TavernChatBox.rect_position.y = g.get_top_of_keyboard_pos() - chat_input.get_size().y - $CanvasLayer/TavernChatBox.get_size().y
		
func _notification(notif):
    if notif == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
        _on_Back_pressed()
    if notif == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        _on_Back_pressed()

func _on_Back_pressed():
	if chat_input.visible == true:
		chat_hide()
		
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
	
func user_exited(id: int) -> void:
	player_info.erase(id) # Erase player from info
	for t in get_tree().get_nodes_in_group("tables"):
		leaving_table(t.table_id, id)

sync func remove_player(id: int) -> void:
	get_node("YSort/"+str(id)).queue_free()
	
func enter_tavern(ip: String, port: float) -> void:
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, port)
	get_tree().set_network_peer(host)

func entered_tavern() -> void:
	rpc("register_player", get_tree().get_network_unique_id(), g.player_data)
	rpc_id(0, "register_tables")
	
### Network Player Registration ###

remote func register_player(id: int, info: Dictionary) -> void:
	## Register players
	player_info[id] = info
	if get_tree().is_network_server():
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])
	rpc("configure_player")
	
remote func register_tables(tables=null) -> void:
	for t in get_tree().get_nodes_in_group("tables"):
		for tb in tables:
			if tb.id == t.get_table_id():
				t.set_table_patrons(tb.patrons)

remote func configure_player() -> void:
	# Load other characters
	for p in player_info:
		if not $YSort.get_node_or_null(str(p)):
			var new_player = player.instance()
			if player_info[p].position == null:
				new_player.position = entrance.position
			else:
				new_player.position = player_info[p].position
			new_player.init(player_info[p].character.gender, player_info[p].character.style, player_info[p].animation, player_info[p].character.name)
			new_player.set_name(str(p))
			new_player.set_network_master(p)
			new_player.set_npc(false)
			$YSort.add_child(new_player)
			barmaid.wave()
	#barmaid.receive_tavern_chat("Welcome!", barmaid.name)
				
func change_scene_manually() -> void:
    # Remove tavern
	var root = get_tree().get_root()
	queue_free()
	
	# Add the proper menu
	var tavern_menu_resource: PackedScene = load("res://Scenes/MainMenu.tscn")
	var tavern_menu: MainMenu = tavern_menu_resource.instance()
	tavern_menu.get_node('TavernSign_Logo').visible = false
	tavern_menu.get_node('TavernMenu').visible = true
	root.add_child(tavern_menu)
	
func leave_tavern() -> void:
	get_tree().set_network_peer(null)
	change_scene_manually()
	## Let tavern API know the character left the tavern

func _server_disconnected() -> void:
	leave_tavern()
	
### Tables ###
sync func update_stool_count(_stool_count) -> void:
	stool_count = _stool_count

func get_min(arr) -> int:
	arr.sort()
	return arr[0]
	
func find_closest_stool(table_id: int, patron: Patron) -> int:
	# dictionary of available stools and their positions
	var stool_pos_dict = {}
	# loop through all stools for availablity
	for stool in stool_count[table_id]:
		var stool_node = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool))
		stool_count[table_id][stool]
		if stool_count[table_id][stool] == null:
		# if stool is available set the stool number as key and distance from patron as value
			stool_pos_dict[(stool_node.get_global_position() - patron.position).length()] = stool
	if stool_pos_dict.keys().size() > 0:
		return stool_pos_dict[get_min(stool_pos_dict.keys())]
	return 0
	
func _on_Table_button_up(table_id: int):
	if table_id == 0 and overhead:
		leaving_table(table_id, get_tree().get_network_unique_id())
		return
	var stool_pos: Vector2
	var patron: Patron = get_node("YSort/"+str(get_tree().get_network_unique_id()))
	if patron.is_busy():
		# If the player is sitting down they can't keep sitting to new stools
		return
	var stool: int = find_closest_stool(table_id, patron)
	if stool == 0:
		# If there are no open stools then the player can't click to join
		return
	var stool_node: Sprite = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool))
	if stool_count[table_id].size() > 2:
		if stool > (stool_count[table_id].size()/2):
			# if the stool is on the bottom row use back animation
			patron.v_sit_anim = 'front'
		else:
			# Else it's the top row and use the front animation
			patron.v_sit_anim = 'back'
		# if stool is empty 
	else:
		if stool > (stool_count[table_id].size()/2):
			# if the stool is on the bottom row use back animation
			patron.v_sit_anim = 'front'
		else:
			# Else it's the top row and use the front animation
			patron.v_sit_anim = 'back'
		# if stool is empty 
		
	if patron.position.x > stool_node.get_global_position().x:
		patron.h_sit_anim = 'Right'
		# if the player is to the right of the stool use right animation and stool position
		if table_id == 0:
			patron.v_sit_anim = 'back'
			# If sitting at bar
			if stool == 1:
				stool_pos = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool)+"/R_P").get_global_position()
			elif stool == 4:
				stool_pos = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool-1)+"/L_P").get_global_position()
			else:
				stool_pos = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool-1)+"/L_P").get_global_position()
		elif stool == 6 or stool == 3:
			stool_pos = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool)+"/R_P").get_global_position()
		else:
			stool_pos = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool+1)+"/L_P").get_global_position()
	else:
		if table_id == 0:
			patron.v_sit_anim = 'back'
		patron.h_sit_anim = 'Left'
		# player is to the left of the stool
		stool_pos = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool)+"/L_P").get_global_position()
	stool_count[table_id][stool] = patron.name
	overhead = true
	rpc("table_join_view", true, int(patron.name), "00"+str(table_id), overhead)
	patron.sit_down(stool_pos, stool, table_id)
	rpc("update_stool_count", stool_count)
	
sync func turn_on_lights(on: bool, c_name: String) -> void:
	if character_name == c_name:
		for t in get_tree().get_nodes_in_group("tables"):
			if get_node_or_null(("YSort/Table_00"+str(t.table_id)+"/Candle/Light2D")) != null:
				get_node(("YSort/Table_00"+str(t.table_id)+"/Candle/Light2D")).enabled = on

func join_table(table_id: int) -> void:
	if not table_id == 0:
		rpc("turn_on_lights", false, character_name)
	chat_hide() # Hides tavern chat
	for t in get_tree().get_nodes_in_group("tables"):
		if t.table_id == table_id:
			t.show()

func leaving_table(table_id: int, id: int) -> void:
	overhead = false
	if not table_id == 0:
		rpc("turn_on_lights", true, character_name)
	else:
		rpc("table_join_view", true, get_tree().get_network_unique_id(), "00"+str(table_id), overhead)
	for stool in stool_count[table_id]:
		#var stool_node = get_node("YSort/Table_00"+str(table_id)+"/Stool_00"+str(stool))
		if stool_count[table_id][stool] != null:
			if stool_count[table_id][stool] == str(id):
				get_node_or_null("YSort/"+stool_count[table_id][stool]).stand_up(stool, table_id)
				stool_count[table_id][stool] = null
				rpc("update_stool_count", stool_count)
				break

func create_table_scenes() -> void:
	for t in range(1, TABLE_COUNT+1):
		# instance packed scene
		var new_table
		if t in GAME_TABLES:
			new_table = game_table.instance()
		else:
			new_table = table.instance()
		new_table.assign(t)
		new_table.set_name("Table" + str(t))
		new_table.hide()
		add_child(new_table)
		new_table.add_to_group("tables")
	
sync func table_join_view(show: bool, id: int, table_id: String, overhead: bool) -> void:
	## TODO: Before release change id to int before it gets in here 
	if get_tree().get_network_unique_id() == id:
		if show:
			get_node('YSort/Table_'+table_id+'/Join').visible = true
			get_node('YSort/Table_'+table_id+'/Join').disabled = false
		else:
			get_node('YSort/Table_'+table_id+'/Join').visible = false
			get_node('YSort/Table_'+table_id+'/Join').disabled = true
		if table_id == '000':
			if overhead:
				get_node('YSort/Table_'+table_id+'/Join').text = "Leave Bar"
			else:
				get_node('YSort/Table_'+table_id+'/Join').text = "Sit at Bar"
				
func table_full(id: int) -> bool:
	# Checks if a table is full of patrons
	for stool in stool_count[id]:
		if stool_count[id][stool] == null:
			return false
	return true
	
func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape, table_id):
	## TODO: change table_id to int of table number instead of leading 00s
	if area != null and not table_full(int(table_id[2])):
		# If there's a player and the table is not full, then show join table and enable the button
		rpc("table_join_view", true, int(area.get_parent().name), table_id, false)
	else:
		rpc("table_join_view", false, int(area.get_parent().name), table_id, false)
	
func _on_Area2D_area_shape_exited(area_id, area, area_shape, self_shape, table_id):
	if area != null:
		rpc("table_join_view", false, int(area.get_parent().name), table_id, false)

### Bulletin Board ###

func _on_Board_button_up():
	board_scene.visible = true
	chat_hide()

sync func board_view(show: bool, id: String) -> void:
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

func update_board_texture() -> void:
	g.make_get_request($YSort/Board/PostCheck, 'tavern/' + g.player_data.tavern.id +'/board')

func _on_PostCheck_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var post_number = len(json.result.data)
	set_board_texture(post_number)
	
func set_board_texture(post_number) -> void:
	if post_number == 0:
		$YSort/Board.set_texture(load("res://Assets/furniture/BulletinBoardA_001.png"))
	elif post_number < 6:
		$YSort/Board.set_texture(load("res://Assets/furniture/BulletinBoardA_002.png"))
	else:
		$YSort/Board.set_texture(load("res://Assets/furniture/BulletinBoardA_003.png"))

func _on_BoardScene_visibility_changed():
	if board_scene.visible:
		get_node("/root/Tavern/YSort/"+str(get_tree().get_network_unique_id())).busy = true
		$ButtonStackAnimation/Chat.disabled = true
		rpc("turn_on_lights", false, character_name)
	else:
		rpc("turn_on_lights", true, character_name)
		$ButtonStackAnimation/Chat.disabled = false
		chat_hide()
		
### Leaving Tavern ###

sync func leave_button_view(show: bool, id: int) -> void:
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

func chat_hide() -> void:
	chat_input.clear()
	chat_input.visible = false

func chat_enter_view() -> void:
	if not chat_input.visible:
		chat_input.visible = true
		chat_input.grab_focus()
		chat_input.rect_position.y = g.get_top_of_keyboard_pos() - chat_input.get_size().y
	else:
		chat_hide()
			
func _on_Chat_button_up():
	chat_enter_view()
	
var command_time: bool = false
var command_param_start = null
var chat_commands: Array = ['yell']

func slash_commands(text: String, params: PoolStringArray) -> void:
	var command: String = text.split(" ")[0].substr(1, len(text)-1)
	if chat_commands.has(command):
		call(command, params)

func _on_ChatEnter_text_entered(new_text: String) -> void:
	chat_input.clear()
	if command_time and command_param_start != null:
		var command_params = new_text.substr(command_param_start, len(new_text)-1)
		command_params = command_params.split(" ")
		command_param_start = null # Resets command param
		slash_commands(new_text, command_params)
	else:
		get_node(str("YSort/"+str(get_tree().get_network_unique_id()))).rpc("receive_tavern_chat", new_text, character_name, get_tree().get_network_unique_id())
		
func _on_ChatEnter_text_changed(new_text: String) -> void:
	if chat_input.text.substr(0,1) == "/":
		command_time = true
	else:
		command_time = false
	if command_time and new_text.substr(1, len(new_text)) in chat_commands:
		command_param_start = len(chat_input.text) + 1
		
func _on_ChatEnter_visibility_changed():
	if chat_input.visible:
		chat_display.visible = true
		chat_display.rect_position.y = g.get_top_of_keyboard_pos() - (chat_input.get_size().y + chat_display.get_size().y)
	else:
		chat_display.visible = false

### Tavern Chat Commands ###

func yell(params: PoolStringArray):
	var msg: String = params.join(" ")
	var tav_msg: String = '[color=#ff4f6d][b]'+msg.to_upper()+'[/b][/color]' ## Increase font or change color to Red maybe?
	var table_msg: String = "yells, "+"\""+msg+"\""
	get_node("YSort/"+str(get_tree().get_network_unique_id())).rpc("receive_tavern_chat", tav_msg, character_name, get_tree().get_network_unique_id())
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

