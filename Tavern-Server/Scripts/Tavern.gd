extends Node2D

const MAX_USERS = 20

export(PackedScene) var table
export(PackedScene) var player

onready var entrance = $Entrance

var character_name = null
var port = null
var tavern_code = null
var tavern_id = null
var player_info = {}

func _ready():
	get_tree().connect("connected_to_server", self, "enter_room")
	get_tree().connect("network_peer_connected", self, "entered_tavern")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	#port = OS.get_cmdline_args()[0]
	#port = port.replace("---", "")
	#tavern_code = OS.get_cmdline_args()[1]
	#tavern_code = port.replace("---", "")
	port = 3000
	tavern_code = "jLRYB"
	host_tavern(port)
	rpc("register_player", get_tree().get_network_unique_id(), global.player_data)
	global.make_post_request($EnterTavern, 'tavern/enter', {"code": tavern_code}, false)
	
func host_tavern(port):
	var host = NetworkedMultiplayerENet.new()
	host.create_server(port, MAX_USERS)
	get_tree().set_network_peer(host)

func leave_tavern():
	get_tree().set_network_peer(null)
	## Close server

func user_exited(id):
	print('exited')
	get_node(str(id)).queue_free()
	player_info.erase(id) # Erase player from info.
	print_tree()
	
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
		var new_player = player.instance()
		new_player.position = entrance.position
		new_player.set_name(str(p))
		new_player.set_network_master(p)
		add_child(new_player)
		
func _server_disconnected():
	leave_tavern()
	
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

func _on_EnterTavern_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var data = json.result.data
	tavern_id = data._id
