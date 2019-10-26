extends Control

onready var menu: MainMenu = get_parent()
onready var invite_code: LineEdit = $Invite/InviteCode
onready var tavern_list: ItemList = $Visited/TavernList

var all_taverns: Array
var tavern_list_data: Array
var selected_tavern
var selected_tavern_index: int
var bow_and_barrel: Dictionary = {
	'_id': '5cf5d8647484f248d4a1e5a6',
	'code': 'dr4Jj',
	'name': 'The Bow and Barrel'
	}

func _ready():
	get_tree().set_auto_accept_quit(false)
	
func _process(delta):
	if g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = g.distance_to_raise(get_focus_owner())
	elif OS.get_virtual_keyboard_height() == 0 and not g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = 0
		
func find_tavern(t: Dictionary) -> bool:
	for tavern in tavern_list_data:
		if t.code == tavern.code:
			return true
	return false
	
func _on_TavernMenu_visibility_changed():
	if visible == true and g.player_data.user_id != null:
		g.make_get_request($AllTaverns, 'tavern/taverns')

func _on_AllTaverns_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	all_taverns = json.result.data
	g.make_get_request($HTTPRequestTaverns, 'users/'+g.player_data.user_id+'/taverns')

func _on_HTTPRequestTaverns_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	populate_tavern_list(json.result.data)

func populate_tavern_list(taverns: Array) -> void:
	tavern_list.clear()
	# if bow and barrel not in taverns add it.
	var has_bow_and_barrel: bool = false
	for tavern in taverns:
		if tavern._id == '5cf5d8647484f248d4a1e5a6':
			has_bow_and_barrel = true
	if !has_bow_and_barrel:
		taverns.append(bow_and_barrel)
	for tavern in taverns:
		for t in all_taverns:
			if t._id == tavern._id:
				tavern['characters'] = t.characters
				tavern_list_data.append(tavern)
				tavern_list.add_item(tavern.name+' ('+str(tavern.characters.size())+')')

func _on_AddTavern_button_up():
	var data: Dictionary = {'code': invite_code.text}
	g.make_post_request($HTTPRequestTavernCheck, 'tavern/check', data )

func _on_HTTPRequestTavernCheck_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if response_code != 404:
		var tavern = json.result.data
		if not find_tavern(tavern):
			tavern_list_data.append(tavern)
			tavern_list.add_item(tavern.name)
			g.make_post_request($HTTPRequestAddTavern, 'users/'+g.player_data.user_id+'/taverns', tavern)
			
func _on_TavernList_item_selected(index):
	selected_tavern_index = index
	var t_name: String = tavern_list.get_item_text(index)
	for t in tavern_list_data:
		if t.name in t_name:
			selected_tavern = t
		
func _on_Remove_button_up():
	if selected_tavern != null:
		g.make_delete_request($HTTPRequestAddTavern, 'users/'+g.player_data.user_id+'/taverns', selected_tavern)
		tavern_list.remove_item(selected_tavern_index)
		tavern_list_data.erase(selected_tavern)

func _on_Enter_button_up():
	if selected_tavern != null:
		selected_tavern["user_id"] = g.player_data.user_id
		selected_tavern["character_id"] = g.player_data.character._id
		g.make_post_request($HTTPRequestEnter, 'tavern/enter', selected_tavern)

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
		visible = false
		g.make_get_request($BoardPostCheck, 'tavern/' + g.player_data.tavern.id +'/board')
		for c in data.characters:
			if c.character_id == g.player_data.character._id:
				g.player_data.character["c_tavern_id"] = c._id

func _on_SpinTavern_request_completed(result, response_code, headers, body):
	var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
	if json.result.data != null:
		get_parent().call_deferred("free")	
		get_tree().change_scene('Scenes/Tavern.tscn')

func _on_BoardPostCheck_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var post_number = len(json.result.data)
	g.player_data.tavern.post_number = post_number
	
func _on_Create_button_up():
	menu.change_menu_scene(self, menu.get_node('CreateTavern'))
	
func _on_Back_button_up():
	menu.change_menu_scene(self, menu.get_node('CharacterSelect'))
