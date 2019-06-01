extends Control

onready var menu = get_parent()
onready var invite_code = $Invite/InviteCode
onready var tavern_list = $Visited/TavernList

var tavern_list_data = []
var selected_tavern
var selected_tavern_index

func _ready():
	#g.make_get_request($HTTPRequestTaverns, 'users/'+g.player_data.user_id+'/taverns'
	pass
	
func _process(delta):
	if g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = g.distance_to_raise(get_focus_owner())
	elif OS.get_virtual_keyboard_height() == 0 and not g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = 0
	
func _on_AddTavern_button_up():
	var data = {'code': invite_code.text}
	g.make_post_request($HTTPRequestTavernCheck, 'tavern/check', data )

func find_tavern(t):
	for tavern in tavern_list_data:
		if t.code == tavern.code:
			return true
	return false

func _on_HTTPRequestEnter_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		var data = json.result.data
		g.make_post_request($SpinTavern, 'tavern/'+data._id+'/server', {})
		g.player_data.tavern = {
			'port': data.port,
			'ip': data.ip,
			'name': data.name,
			'code': data.code,
			'id': data._id
		}
		g.player_data.table_id = 0
		visible = false

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
			g.make_post_request($HTTPRequestAddTavern, 'users/'+g.player_data.user_id+'/taverns', tavern)

func _on_Enter_button_up():
	print(g.player_data.tavern )
	if selected_tavern != null and g.player_data.tavern.id == null:
		g.make_post_request($HTTPRequestEnter, 'tavern/enter', selected_tavern)
	else:
		g.make_post_request($SpinTavern, 'tavern/'+g.player_data.tavern.id+'/server', {})
		# TODO: Error handling
		
func _on_Remove_button_up():
	if selected_tavern != null:
		g.make_delete_request($HTTPRequestAddTavern, 'users/'+g.player_data.user_id+'/taverns', selected_tavern)
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
		g.make_get_request($HTTPRequestTaverns, 'users/'+g.player_data.user_id+'/taverns')

func _on_Create_button_up():
	menu.change_menu_scene(self, menu.get_node('CreateTavern'))

func _on_SpinTavern_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(result)
	print(json)
	print(json.result)
	if json.result.data != null:
		get_parent().call_deferred("free")	
		get_tree().change_scene('Scenes/Tavern.tscn')
