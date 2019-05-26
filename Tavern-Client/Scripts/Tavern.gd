extends Node2D

export(PackedScene) var table
export(PackedScene) var player
export(PackedScene) var board

var character_name = null
var player_info = {}

onready var entrance = $Entrance
onready var board_button = $YSort/Board/BoardButton
onready var chat_input = $ChatEnter

func _ready():
	get_tree().connect("connected_to_server", self, "entered_tavern")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	if global.player_data.tavern.ip != null and global.player_data.tavern.port != null and global.player_data.table_id == 0:
		update_board_texture()
		character_name = global.player_data.character.name
		create_table_scenes()
		enter_tavern(global.player_data.tavern.ip, global.player_data.tavern.port)

func user_exited(id):
	get_node(str(id)).queue_free()
	player_info.erase(id) # Erase player from info.
	
func enter_tavern(ip, port):
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, port)
	get_tree().set_network_peer(host)

func entered_tavern():
	rpc("register_player", get_tree().get_network_unique_id(), global.player_data)
	
### Network Player Registration ###

remote func register_player(id, info):
	## Register players
	player_info[id] = info
	if get_tree().is_network_server():
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])
	rpc("configure_player")

remote func configure_player():
	# Load other characters
	for p in player_info:
		print(str(p))
		if not get_node_or_null(str(p)):
			var new_player = player.instance()
			if player_info[p].position == null:
				new_player.position = entrance.position
			else:
				new_player.position = player_info[p].position
			new_player.gender = player_info[p].character.gender
			new_player.set_name(str(p))
			new_player.set_network_master(p)
			$YSort.add_child(new_player)
	
func leave_tavern():
	get_tree().set_network_peer(null)
	## Let tavern API know the character left the tavern
	get_tree().change_scene('Scenes/TavernMenu.tscn')

func _server_disconnected():
	leave_tavern()
	
### Tables ###
	
func _on_Table_button_up(table_id):
	join_table(table_id)
	
func join_table(table_id):
	for t in get_tree().get_nodes_in_group("tables"):
		if t.table_id == table_id:
			t.show()

func create_table_scenes():
	for t in range(1, 4):
		# instance packed scene
		var new_table = table.instance()
		new_table.assign(t)
		new_table.set_name("Table" + str(t))
		new_table.hide()
		add_child(new_table)
		new_table.add_to_group("tables")
		# 

sync func table_join_view(show, id, table_id):
	if get_tree().get_network_unique_id() == int(id):
		if show:
			get_node('YSort/Table_'+table_id+'/Join').visible = true
			get_node('YSort/Table_'+table_id+'/Join').disabled = false
		else:
			get_node('YSort/Table_'+table_id+'/Join').visible = false
			get_node('YSort/Table_'+table_id+'/Join').disabled = true

func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape, table_id):
	rpc("table_join_view", true, body.name, table_id)

func _on_Area2D_body_shape_exited(body_id, body, body_shape, area_shape, table_id):
	rpc("table_join_view", false, body.name, table_id)

### Bulletin Board ###
		
func _on_Board_button_up():
	var board_instance = board.instance()
	add_child(board_instance)
	
sync func board_view(show, id):
	if get_tree().get_network_unique_id() == int(id):
		if show:
			board_button.visible = true
			board_button.disabled = false
		else:
			board_button.visible = false
			board_button.disabled = true
			
func _on_BoardArea_body_entered(body):
	rpc("board_view", true, body.name)

func _on_BoardArea_body_exited(body):
	rpc( "board_view", false, body.name)
	
func update_board_texture():
	global.make_get_request($YSort/Board/PostCheck, 'tavern/' + global.player_data.tavern.id +'/board', false)

func _on_PostCheck_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var post_number = len(json.result.data)
	if post_number == 0:
		$YSort/Board.set_texture(load("res://Assets/furniture/BulletinBoardA_001.png"))
	elif post_number < 6:
		$YSort/Board.set_texture(load("res://Assets/furniture/BulletinBoardA_002.png"))
	else:
		$Board.set_texture(load("res://Assets/furniture/BulletinBoardA_003.png"))

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

sync func chat_enter_view(show, id):
	if show:
		if id == get_tree().get_network_unique_id():
			$ChatEnter.visible = true
			$ChatEnter.grab_focus()
	else:
		if id == get_tree().get_network_unique_id():
			$ChatEnter.visible = false
			
func _on_Chat_button_up():
	rpc("chat_enter_view", true, get_tree().get_network_unique_id())
	
var command_time = false
var command_param_start = null
var chat_commands = ['yell']

func slash_commands(text, params):
	var command = text.split(" ")[0].substr(1, len(text)-1)
	if chat_commands.has(command):
		pass
		call(command, params)

func _on_ChatEnter_text_entered(new_text):
	if command_time and command_param_start != null:
		var command_params = new_text.substr(command_param_start, len(new_text)-1)
		command_params = command_params.split(" ")
		command_param_start = null # Resets command param
		slash_commands(new_text, command_params)
	else:
		get_node(str(get_tree().get_network_unique_id())).rpc("receive_tavern_chat", new_text, get_tree().get_network_unique_id())
		$ChatEnter.clear()
		rpc("chat_enter_view", false, get_tree().get_network_unique_id())

func _on_ChatEnter_text_changed(new_text):
	if chat_input.text.substr(0,1) == "/":
		command_time = true
	else:
		command_time = false
	if command_time and new_text.substr(len(new_text)-1, len(new_text)-1) == " " and command_param_start == null:
		command_param_start = len(chat_input.text)

### Tavern Chat Commands ###

func yell(params):
	var msg = params.join(" ")
	var tav_msg = '[color=#ff4f6d]'+msg+'[/color]' ## Increase font or change color to Red maybe?
	var table_msg = "yells, "+"\""+msg+"\""
	get_node(str(get_tree().get_network_unique_id())).rpc("receive_tavern_chat", tav_msg, get_tree().get_network_unique_id())
	$ChatEnter.clear()
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


func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	print(area.get_parent().name)
