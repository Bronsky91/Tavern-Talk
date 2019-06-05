extends Control

onready var new_tavern_name = $Title/NewTavern
onready var menu = get_parent()

func _ready():
	get_tree().set_auto_accept_quit(false)
	
func _process(delta):
	if g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = g.distance_to_raise(get_focus_owner())
	elif OS.get_virtual_keyboard_height() == 0 and not g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = 0
	
func _on_CreateTavern_button_up():
	var data = {
		'name': new_tavern_name.text,
		'character': {
			'user_id': g.player_data.user_id,
			'character_d': g.player_data.character._id,
			'table': 0
			}
		}
	if len(new_tavern_name.text) > 0:
		## TODO: Error message handling
		g.make_post_request($HTTPRequestCreate, 'tavern/taverns', data)
		
func _on_HTTPRequestCreate_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var data = json.result.data
	print(data)
	#if data.port != "No available ports":
	#	$Error.text = "Unable to create new Tavern, server is full"
	## TODO: Make check to see if tavern was created
	g.player_data.tavern = {
		'port': data.port,
		'ip': data.ip,
		'name': data.name,
		'code': data.code,
		'id': data._id
		}
	g.player_data.table_id = 0
	var tavern =  {
		'name': data.name,
		'code': data.code
		}
	menu.get_node("TavernMenu").tavern_list_data.append(tavern)
	menu.get_node("TavernMenu").tavern_list.add_item(tavern.name)
	g.make_post_request(menu.get_node("TavernMenu/HTTPRequestAddTavern"), 'users/'+g.player_data.user_id+'taverns', tavern)
	$Title/Label/Code.bbcode_text = "[center][b]"+data.code+"[/b][/center]"

func _on_Back_button_up():
	menu.change_menu_scene(self, menu.get_node('TavernMenu'))