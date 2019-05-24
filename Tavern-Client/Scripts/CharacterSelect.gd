extends Control

onready var menu = get_parent()
# listitem node that holds selectable character choices
onready var character_list = $Characters

var character_list_data = []
var selected_character = {}

func _ready():
	pass

func populate_characters(characters):
	character_list.clear()
	for character in characters:
		character_list_data.append(character)
		character_list.add_item(character.name)
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json)
	if response_code == 404:
		global.make_get_request($CharacterFetch, 'users/' + global.player_data.user_id, false)
	else:
		var characters = json.result.data.characters
		populate_characters(characters)

func _on_NewCharacterButton_button_up():
	menu.change_menu_scene(self, menu.get_node('CharacterCreate'))

func _on_Characters_item_selected(index):
	var c_name = character_list.get_item_text(index)
	for c in character_list_data:
		if c.name == c_name:
			selected_character = c

func _on_Remove_button_up():
	var data = {"_id": selected_character._id}
	global.make_patch_request($CharacterFetch, 'users/' + global.player_data.user_id + '/character_remove', data, false)

func _on_JoinButton_button_up():
	global.player_data.character = selected_character
	menu.change_menu_scene(self, menu.get_node('TavernMenu'))

func _on_CharacterSelect_visibility_changed():
	if visible == true:
		global.make_get_request($CharacterFetch, 'users/' + global.player_data.user_id, false)
