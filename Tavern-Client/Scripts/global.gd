extends Node

var player_data: Dictionary = {
	'user_id': null, # String
	'character': {
		'_id': null, # String
		'name': null, # String
		'race': null, # String
		'gender': null, # String
		'stats':{
			'strength': null, # Int
			'dex': null, # Int
			'con': null, # Int
			'wis': null, # Int
			'char': null # Int
			},
		'style': {
			'skin': null, # String
			'hair': null, # String
			'eyes': null, # String
			'top_clothes': null, # String
			'bottom_clothes': null, # String
			'accessory': null # String
		},
		'inventory': {
			'gold': null, # Int
			'items': [
				{
					# name: String,
		            # about: String,
		            # worth: Int,
		            # icon: String,
		            # texture: String,
		            # clothing: bool
				}
			]
		}
	},
	'tavern': {
		'port': null, # Int
		'ip': null, # String
		'name': null, # String
		'code': null, # String
		'id': null, # String
		'post_number': null, # Int
		},
	'table_id': null, # Int,
	'position': null,
	'last_scene': null,
	'animation': null
	}
	
var api_url: String = 'https://warlock.tech/api/'
var headers: Array = ["Content-Type: application/json",
				"Authorization: Basic YWRtaW46c3RyaWZlbG9yZA=="]
				
func _ready():
	pass

func make_get_request(request: HTTPRequest, url: String) -> void:
	request.request(api_url + url, headers, false, HTTPClient.METHOD_GET)
	
func make_post_request(request: HTTPRequest, url: String, data: Dictionary):
	var query = JSON.print(data)
	request.request(api_url + url, headers, false, HTTPClient.METHOD_POST, query)
	
func make_patch_request(request: HTTPRequest, url: String, data: Dictionary):
	var query = JSON.print(data)
	request.request(api_url + url, headers, false, HTTPClient.METHOD_PATCH, query)
	
func make_delete_request(request: HTTPRequest, url: String, data: Dictionary):
	var query = JSON.print(data)
	request.request(api_url + url, headers, false, HTTPClient.METHOD_DELETE, query)

func calc_stat_mod(score: int) -> int:
	if score < 10:
		return (((score - 10) / 2) + 10) - 10
	else:
		return (score - 10) / 2

func distance_to_raise(canvas_node) -> int:
	if not is_lower_than_keyboard(canvas_node):
		return 0
	return get_top_of_keyboard_pos() - (canvas_node.get_global_position().y + canvas_node.get_size().y)
	
func is_lower_than_keyboard(ledit) -> bool:
	if ledit != null and get_top_of_keyboard_pos() != get_viewport().size.y:
		return (ledit.get_global_position().y + ledit.get_size().y) > get_top_of_keyboard_pos()
	return false
	
func get_top_of_keyboard_pos() -> float:
	var scale_x = floor(OS.get_window_size().x / ProjectSettings.get_setting("display/window/size/width"))
	var scale_y = floor(OS.get_window_size().y / ProjectSettings.get_setting("display/window/size/height"))
	var screen_scale = max(1, min(scale_x, scale_y))
	if OS.get_virtual_keyboard_height() != 0:
		return get_viewport().size.y - (OS.get_virtual_keyboard_height() / screen_scale)
	return get_viewport().size.y

func remember_me(login: Dictionary) -> void:
	var f: File = File.new()
	f.open("user://login.save", File.READ)
	var json: JSONParseResult = JSON.parse(f.get_as_text())
	f.close()
	var data: Dictionary = json.result
	data = {"username": login["username"], "password": login["password"], "remember": login["remember"]}
	# Save
	f = File.new()
	f.open("user://login.save", File.WRITE)
	f.store_string(JSON.print(data, "  ", true))
	f.close()
	
func load_login() -> Dictionary:
	var save_login: File = File.new()
	save_login.open("user://login.save", File.READ)
	var text: String = save_login.get_as_text()
	var login: Dictionary = parse_json(text)
	save_login.close()
	return login

func roll(num_of_dice, dice_sides) -> Array:
	var roll_result: Array = []
	for i in range(0, int(num_of_dice)):
		randomize()
		roll_result.append(randi() % int(dice_sides) + 1)
	return roll_result
	
func count_files_in_dir(path: String) -> int:
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and not file.ends_with(".import"):
			files.append(file)
	dir.list_dir_end()
	return len(files)