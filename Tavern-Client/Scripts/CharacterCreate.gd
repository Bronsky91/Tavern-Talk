extends Control

onready var character_name = $NameLabel/Name
onready var gender_list = $GenderLabel/Gender

var gender = ""

func _ready():
	gender_list.add_item("Male")
	gender_list.add_item("Female")

func _on_Create_request_completed(result, response_code, headers, body):
	print(response_code)
	if response_code == 200:
		get_tree().change_scene('Scenes/CharacterSelect.tscn')

func _on_CreateButton_button_up():
	var data = {
		"characters": {
			"name": character_name.text,
			"gender": gender
		}
	}
	print(global.player_data.user_id)
	global.make_patch_request($Create, 'users/' + global.player_data.user_id, data, false)

func _on_Back_button_up():
	get_tree().change_scene("Scenes/CharacterSelect.tscn")

func _on_Gender_item_selected(index):
	gender = gender_list.get_item_text(index)
