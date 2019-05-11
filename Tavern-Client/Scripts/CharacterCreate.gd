extends Control

onready var character_name = $NameLabel/Name

func _ready():
	pass 

func _on_Create_request_completed(result, response_code, headers, body):
	if response_code == 200:
		get_tree().change_scene('Scenes/CharacterSelect.tscn')

func _on_CreateButton_button_up():
	var data = {'characters': {"name": character_name.text}}
	global.make_patch_request($Create, global.api_url + 'users/' + global.player_data.user_id, data, false)

func _on_Back_button_up():
	get_tree().change_scene("Scenes/CharacterSelect.tscn")
