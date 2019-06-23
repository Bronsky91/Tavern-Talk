extends Node2D

export(PackedScene) var barrel_roll

var table_id

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_disconnected", self, "user_exited")

func assign(_table_id):
	table_id = _table_id
	
func get_table_id():
	return table_id

func _on_Leave_button_up():
	get_parent().leaving_table(table_id, get_tree().get_network_unique_id())
	if get_node_or_null("Map") != null:
		get_node("Map").call_deferred("free")
	.hide()

func _on_Game1_button_up():
	var new_game = barrel_roll.instance()
	new_game.z_index = 5
	add_child(new_game)
