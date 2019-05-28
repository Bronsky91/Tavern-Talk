extends Control

onready var new_tavern_name = $Title/NewTavern
onready var menu = get_parent()

func _ready():
	pass
	
func _on_CreateTavern_button_up():
	var data = {
		'name': new_tavern_name.text,
		'character': {
			'user_id': global.player_data.user_id,
			'character_d': global.player_data.character._id,
			'table': 0
			}
		}
	if len(new_tavern_name.text) > 0:
		## TODO: Error message handling
		global.make_post_request($HTTPRequestCreate, 'tavern/taverns', data)
		
func _on_HTTPRequestCreate_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var data = json.result.data
	print(data)
	if data.port == "No available ports":
		$Error.text = "Unable to create new Tavern, server is full"
	## TODO: Make check to see if tavern was created
	global.player_data.tavern = {
		'port': data.port,
		'ip': data.ip,
		'name': data.name,
		'code': data.code,
		'id': data._id
		}
	global.player_data.table_id = 0
	var tavern =  {
		'name': data.name,
		'code': data.code
		}
	menu.get_node("TavernMenu").tavern_list_data.append(tavern)
	menu.get_node("TavernMenu").tavern_list.add_item(tavern.name)
	global.make_post_request(menu.get_node("TavernMenu/HTTPRequestAddTavern"), 'users/'+global.player_data.user_id+'taverns', tavern)
	menu.change_menu_scene(self, menu.get_node('TavernMenu'))

func _on_Back_button_up():
	menu.change_menu_scene(self, menu.get_node('TavernMenu'))
