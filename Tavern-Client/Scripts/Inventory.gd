extends NinePatchRect

onready var inventory = $Inventory

func _ready():
	g.make_get_request(inventory, 'users/'+g.player_data.user_id+'/'+g.player_data.character._id+'/inventory')

func update_inventory(gold: int = 0, items: Array = []) -> void:
	## gold is not the total but the change + -
	var data = {'gold': gold, 'items': items}
	g.make_post_request(inventory, 'users/'+g.player_data.user_id+'/'+g.player_data.character._id+'/inventory', data)

func _on_Inventory_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var inv = json.result.inventory
	var msg = json.result.msg
