extends Node2D

const MAX_USERS = 20

export(PackedScene) var table

var character_name = null
var port = null
var tavern_code = null
var tavern_id = null

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
	global.make_post_request($EnterTavern, 'tavern/enter', {"code": tavern_code}, false)
	
func host_tavern(port):
	var host = NetworkedMultiplayerENet.new()
	host.create_server(port, MAX_USERS)
	get_tree().set_network_peer(host)

func leave_tavern():
	get_tree().set_network_peer(null)
	## Close server

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
