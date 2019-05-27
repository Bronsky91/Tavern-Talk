extends Control

onready var menu = get_parent()
onready var invite_code = $Invite/InviteCode
onready var tavern_list = $Visited/TavernList

var tavern_list_data = []
var selected_tavern
var selected_tavern_index

func _ready():
	#global.make_get_request($HTTPRequestTaverns, 'users/'+global.player_data.user_id+'/taverns', false)
	pass
	
func _on_AddTavern_button_up():
	var data = {'code': invite_code.text}
	global.make_post_request($HTTPRequestTavernCheck, 'tavern/check', data, false )

func find_tavern(t):
	for tavern in tavern_list_data:
		if t.code == tavern.code:
			return true
	return false

func _on_HTTPRequestEnter_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		var data = json.result.data
		global.player_data.tavern = {
			'port': data.port,
			'ip': data.ip,
			'name': data.name,
			'code': data.code,
			'id': data._id
		}
		global.player_data.table_id = 0
		visible = false
		get_tree().change_scene('Scenes/Tavern.tscn')

func _on_Back_button_up():
	menu.change_menu_scene(self, menu.get_node('CharacterSelect'))
	
func populate_tavern_list(taverns):
	tavern_list.clear()
	for tavern in taverns:
		tavern_list_data.append(tavern)
		tavern_list.add_item(tavern.name)

func _on_HTTPRequestTaverns_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	populate_tavern_list(json.result.data)

func _on_HTTPRequestTavernCheck_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if response_code != 404:
		var tavern = json.result.data
		if not find_tavern(tavern):
			tavern_list_data.append(tavern)
			tavern_list.add_item(tavern.name)
			global.make_post_request($HTTPRequestAddTavern, 'users/'+global.player_data.user_id+'/taverns', tavern, false)

func _on_Enter_button_up():
	if selected_tavern != null:
		global.make_post_request($HTTPRequestEnter, 'tavern/enter', selected_tavern, false )
	else:
		pass
		# TODO: Error handling
		
func _on_Remove_button_up():
	if selected_tavern != null:
		global.make_delete_request($HTTPRequestAddTavern, 'users/'+global.player_data.user_id+'/taverns', selected_tavern, false)
		tavern_list.remove_item(selected_tavern_index)
		tavern_list_data.erase(selected_tavern)

func _on_TavernList_item_selected(index):
	selected_tavern_index = index
	var t_name = tavern_list.get_item_text(index)
	for t in tavern_list_data:
		if t.name == t_name:
			selected_tavern = t

func _on_TavernMenu_visibility_changed():
	if visible == true:
		global.make_get_request($HTTPRequestTaverns, 'users/'+global.player_data.user_id+'/taverns', false)

func _on_Create_button_up():
	menu.change_menu_scene(self, menu.get_node('CreateTavern'))
