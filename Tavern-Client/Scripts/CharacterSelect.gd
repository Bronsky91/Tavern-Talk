extends Control

onready var menu = get_parent()
# listitem node that holds selectable character choices
onready var character_list = $Characters
onready var delete_confirm = $CanvasLayer/ConfirmationDialog

var character_list_data = []
var selected_character = {'_id': null}

func _ready():
	get_tree().set_auto_accept_quit(false)
	
func _process(delta):
	if g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = g.distance_to_raise(get_focus_owner())
	elif OS.get_virtual_keyboard_height() == 0 and not g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = 0
	
func populate_characters(characters):
	character_list.clear()
	for character in characters:
		character_list_data.append(character)
		character_list.add_item(character.name)
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if response_code == 404:
		g.make_get_request($CharacterFetch, 'users/' + g.player_data.user_id)
	else:
		var characters = json.result.data.characters
		populate_characters(characters)

func _on_NewCharacterButton_button_up():
	menu.get_node('CharacterCreate').edit_mode = false
	menu.get_node('CharacterCreate').character_data = {}
	menu.change_menu_scene(self, menu.get_node('CharacterCreate'))

func _on_Characters_item_selected(index):
	$Error.text = ""
	var c_name = character_list.get_item_text(index)
	for c in character_list_data:
		if c.name == c_name:
			selected_character = c
			
func _on_Edit_button_up():
	if selected_character._id != null:
		menu.get_node('CharacterCreate').edit_mode = true
		menu.get_node('CharacterCreate').character_data = selected_character
		menu.get_node('CharacterCreate').c_id = selected_character._id
		menu.change_menu_scene(self, menu.get_node('CharacterCreate'))
	else:
		$Error.text = "Select a character to edit"

func _on_Remove_button_up():
	if selected_character._id != null:
		delete_confirm.dialog_text = "Are you sure you wish to delete the Character: "+selected_character.name+"?"
		delete_confirm.popup_centered()
	
func _on_JoinButton_button_up():
	if selected_character._id == null:
		$Error.text = "A Character must be selected before continuing"
	else:
		g.player_data.character = selected_character
		menu.change_menu_scene(self, menu.get_node('TavernMenu'))

func _on_CharacterSelect_visibility_changed():
	if visible == true and g.player_data.user_id != null:
		g.make_get_request($CharacterFetch, 'users/' + g.player_data.user_id)

func _on_Back_button_up():
	selected_character = {'_id': null}
	menu.change_menu_scene(self, menu.get_node('Login'))

func _on_ConfirmationDialog_confirmed():
	var data = {"_id": selected_character._id}
	g.make_patch_request($CharacterFetch, 'users/' + g.player_data.user_id + '/character_remove', data)
	
