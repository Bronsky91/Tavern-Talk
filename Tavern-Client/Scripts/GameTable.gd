extends Node2D

export(PackedScene) var barrel_roll

var table_id: int

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	
func user_exited(id: int) -> void:
	get_parent().leaving_table(table_id, id)
		
func assign(_table_id: int) -> void:
	table_id = _table_id
	
func get_table_id() -> int:
	return table_id
	
func _notification(notif):
    if notif == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
        _on_Leave_button_up()
    if notif == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        _on_Leave_button_up()
		
func _on_Leave_button_up():
	get_parent().leaving_table(table_id, get_tree().get_network_unique_id())
	if get_node_or_null("Map") != null:
		get_node("Map").call_deferred("free")
	.hide()

func _on_Game1_button_up():
	var new_game: BarrelRoll = barrel_roll.instance()
	new_game.z_index = 5
	add_child(new_game)
