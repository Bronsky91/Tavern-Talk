extends Control

# listitem node that holds selectable character choices
onready var character_list = $Characters

var character_list_data = []
var selected_character_id = null
var selected_character_name = null

func _ready():
	make_get_request(global.api_url + 'users/' + global.player_data.user_id, false)

func populate_characters(characters):
	character_list.clear()
	for character in characters:
		character_list_data.append(character)
		character_list.add_item(character.name)
	
func make_get_request(url, use_ssl):
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request(url)
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if response_code == 404:
		return
	else:
		var characters = json.result.data.characters
		populate_characters(characters)

func _on_NewCharacterButton_button_up():
	get_tree().change_scene("Scenes/CharacterCreate.tscn")

func _on_Characters_item_selected(index):
	var c_name = character_list.get_item_text(index)
	for c in character_list_data:
		if c.name == c_name:
			selected_character_id = c._id
			selected_character_name = c_name

func _on_Remove_button_up():
	var headers = ["Content-Type: application/json"]
	var data = {"_id": selected_character_id}
	var query = JSON.print(data)
	$HTTPRequest.request(global.api_url + 'users/' + global.user_id + '/character_remove', headers, false, HTTPClient.METHOD_PATCH, query)

func _on_JoinButton_button_up():
	global.player_data.character.id = selected_character_id
	global.player_data.character.name = selected_character_name
	get_tree().change_scene("Scenes/TavernMenu.tscn")
