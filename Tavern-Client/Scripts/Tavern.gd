extends Node2D

export(PackedScene) var table
export(PackedScene) var player

var character_name = null
var player_info = {}

onready var entrance = $Entrance

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "entered_tavern")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	if global.player_data.tavern.ip != null and global.player_data.tavern.port != null and global.player_data.table_id == 0:
		character_name = global.player_data.character.name
		create_table_scenes()
		enter_tavern(global.player_data.tavern.ip, global.player_data.tavern.port)

func user_exited(id):
	print('exited')
	get_node(str(id)).queue_free()
	player_info.erase(id) # Erase player from info.
	
func enter_tavern(ip, port):
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, port)
	get_tree().set_network_peer(host)

func entered_tavern():
	rpc("register_player", get_tree().get_network_unique_id(), global.player_data)
	
remote func register_player(id, info):
	## Register players
	player_info[id] = info
	print(player_info[id])
	if get_tree().is_network_server():
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])
	rpc("configure_player")

remote func configure_player():
	# Load other characters
	for p in player_info:
		if not get_node_or_null(str(p)):
			var new_player = player.instance()
			if player_info[p].position == null:
				new_player.position = entrance.position
			else:
				new_player.position = player_info[p].position
			new_player.set_name(str(p))
			new_player.set_network_master(p)
			add_child(new_player)
		
func leave_tavern():
	get_tree().set_network_peer(null)
	## Let tavern API know the character left the tavern
	get_tree().change_scene('Scenes/TavernMenu.tscn')

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

func _on_Board_button_up():
		get_tree().change_scene("Scenes/Board.tscn")

func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape, table_id):
	get_node('Table_'+table_id+'/Join').visible = true
	get_node('Table_'+table_id+'/Join').disabled = false

func _on_Area2D_body_shape_exited(body_id, body, body_shape, area_shape, table_id):
	get_node('Table_'+table_id+'/Join').visible = false
	get_node('Table_'+table_id+'/Join').disabled = true
