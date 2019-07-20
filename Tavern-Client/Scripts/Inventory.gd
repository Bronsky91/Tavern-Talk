extends NinePatchRect

onready var inventory = $Inventory

func _ready():
	g.make_get_request(inventory, 'users/'+g.player_data.user_id+'/'+g.player_data.character._id+'/inventory')
	$CharacterPanel/CharacterView/Body.set_texture(load("res://Assets/Characters/"+g.player_data.character.gender+"_Idle_00"+str(g.player_data.character.style.skin)+".png"))
	$CharacterPanel/CharacterView/Body/Hair.set_texture(load("res://Assets/Characters/"+g.player_data.character.gender+"_IdleHair_00"+str(g.player_data.character.style.hair)+".png"))
	$CharacterPanel/CharacterView/Body/Eyes.set_texture(load("res://Assets/Characters/"+g.player_data.character.gender+"_IdleEyes_00"+str(g.player_data.character.style.eyes)+".png"))
	$CharacterPanel/CharacterView/Body/Clothes.set_texture(load("res://Assets/Characters/"+g.player_data.character.gender+"_IdleClothes_00"+str(g.player_data.character.style.clothes)+".png"))
	$CharacterPanel/CharacterView/AnimationPlayer.current_animation = "idle_down_menu"

func update_inventory(gold: int = 0, items: Array = []) -> void:
	## gold is not the total but the change + -
	var data = {'gold': gold, 'items': items}
	g.make_post_request(inventory, 'users/'+g.player_data.user_id+'/'+g.player_data.character._id+'/inventory', data)

func _on_Inventory_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var inv = json.result.inventory
	var msg = json.result.msg
	$Bag/Currency/GoldAmount.text = str(inv.gold)

func _on_Inventory_visibility_changed():
	pass # Replace with function body.
	
		