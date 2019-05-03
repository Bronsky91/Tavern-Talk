extends Node2D

const MAX_USERS = 20

export(PackedScene) var table

onready var tavern_name = $TavernName

var character_name = null
var number_of_tables = null
var port = null
var tavern_code = null
var tavern_id = null
var setup_run = true

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

func get_table_stats():
	# makes HTTPRequest to refresh the character count for each table
	var headers = ["Content-Type: application/json"]
	$RefreshCountTimer/TableRefresh.request(global.api_url + 'tavern/' + tavern_id + '/tables')
	
func _on_RefreshCountTimer_timeout():
	get_table_stats()

func find_table(table_id):
	var tables = {1: $Count1, 2: $Count2, 3: $Count3, 4: $Count4}
	return tables[table_id]

func _on_TableRefresh_request_completed(result, response_code, headers, body):
	var n_tables = 0 # number of tables on this request
	var json = JSON.parse(body.get_string_from_utf8())
	for table_id in json.result.data.keys():
		n_tables = n_tables + 1
		find_table(int(table_id)).text = "Player Count: " + str(json.result.data[table_id])
	number_of_tables = n_tables # Updates the total number of tables in the tavern
	create_table_nodes()

func create_table_nodes():
	if setup_run:
		setup_run = false
		for t in range(1, number_of_tables + 1):
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
	
	get_table_stats()
