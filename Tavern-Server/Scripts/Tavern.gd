extends Node2D

const MAX_USERS = 20

export(PackedScene) var table
export(PackedScene) var player
export(PackedScene) var board

onready var entrance = $Entrance
onready var board_button = $Board/BoardButton

var character_name = null
var port = null
var tavern_code = null
var tavern_id = null
var player_info = {}
var registered = false

var stool_count = {
	0: { # Bar
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
	get_tree().connect("connected_to_server", self, "entered_tavern")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	port = OS.get_cmdline_args()[0]
	port = port.replace("---", "")
	tavern_id = OS.get_cmdline_args()[1]
	tavern_id = tavern_id.replace("---", "")
	host_tavern(port)
	create_table_scenes()
	
func host_tavern(port):
	var host = NetworkedMultiplayerENet.new()
	host.create_server(port, MAX_USERS)
	get_tree().set_network_peer(host)

func leave_tavern():
	get_tree().set_network_peer(null)
	## Close server
	
func entered_tavern():
	print('user entered tavern')
	
func user_exited(id):
	print('exited')
	rpc('remove_player', id)
	player_info.erase(id) # Erase player from info.
	
func current_patron_check() -> Array:
	var current_patrons = []
	for id in player_info:
		current_patrons.append({'_id': player_info[id].character.c_tavern_id, 'user_id': player_info[id].user_id, 'character_id': player_info[id].character._id})
	return current_patrons

func _on_CheckTimer_timeout():
	global.make_get_request($PatronList, 'tavern/'+tavern_id)

func _on_PatronList_request_completed(result, response_code, headers, body):
	var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
	var data: Dictionary = json.result.data
	for c in current_patron_check():
		for ch in data.characters:
			if ch._id == c._id:
				data.characters.erase(ch)
	global.make_patch_request($RemoveAbsentPlayers, 'tavern/'+tavern_id+'/character_remove', data.characters)

sync func remove_player(id):
	get_node("YSort/"+str(id)).call_deferred('free')

remote func register_player(id, info):
	## Register players
	player_info[id] = info
	if get_tree().is_network_server():
		for peer_id in player_info:
			print('peer_id: '+str(peer_id))
			rpc("register_player", peer_id, player_info[peer_id])
	rpc("configure_player")
	
remote func register_tables(tables=null):
	if get_tree().is_network_server():
		var tables_list = []
		for t in get_tree().get_nodes_in_group("tables"):
			var table_dict = {}
			table_dict['patrons'] = t.get_current_patrons()
			table_dict['id'] = t.get_table_id()
			tables_list.append(table_dict)
		rpc_id(get_tree().get_rpc_sender_id(), "register_tables", tables_list)
		rpc("update_stool_count", stool_count)

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
		
func _server_disconnected():
	leave_tavern()
	
func _on_Table_button_up(table_id):
	join_table(table_id)

sync func update_stool_count(_stool_count):
	stool_count = _stool_count
	
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

#func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape, table_id):
#	get_node('Table_'+table_id+'/Join').visible = true
#	get_node('Table_'+table_id+'/Join').disabled = false

#func _on_Area2D_body_shape_exited(body_id, body, body_shape, area_shape, table_id):
#	get_node('Table_'+table_id+'/Join').visible = false
#	get_node('Table_'+table_id+'/Join').disabled = true


#func _on_BoardArea_body_entered(body):
#	board_button.visible = true
#	board_button.disabled = false


#func _on_BoardArea_body_exited(body):
#	board_button.visible = false
#	board_button.disabled = true
	

