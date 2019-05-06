extends Control

onready var character_name = $NameLabel/Name

func _ready():
	pass 
	
func make_patch_request(url, data, use_ssl):
	var query = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request(url, headers, use_ssl, HTTPClient.METHOD_PATCH, query)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print(result)
	if response_code == 200:
		get_tree().change_scene('Scenes/CharacterSelect.tscn')

func _on_CreateButton_button_up():
	var data = {'characters': {"name": character_name.text}}
	make_patch_request(global.api_url + 'users/' + global.player_data.user_id, data, false)

func _on_Back_button_up():
	get_tree().change_scene("Scenes/CharacterSelect.tscn")
