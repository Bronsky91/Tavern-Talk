extends Node2D

export(PackedScene) var table
export(PackedScene) var player

var character_name = null

onready var entrance = $Entrance

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connected_to_server", self, "entered_tavern")
	if global.player_data.tavern.ip != null and global.player_data.tavern.port != null and global.player_data.table_id == 0:
		character_name = global.player_data.character.name
		create_table_scenes()
		enter_tavern(global.player_data.tavern.ip, global.player_data.tavern.port)

func enter_tavern(ip, port):
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, port)
	get_tree().set_network_peer(host)

func entered_tavern():
	configure_player()

func configure_player():
	var new_player = player.instance()
	new_player.position = entrance.position
	## TODO: Set player appearence from global.player_data
	add_child(new_player)
	global.player_data.network.id = get_tree().get_network_unique_id()
	
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
