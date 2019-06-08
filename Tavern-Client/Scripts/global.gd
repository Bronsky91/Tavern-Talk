extends Node

var player_data = {
	'user_id': null,
	'character': {
		'_id': null,
		'name': null,
		'gender': null,
		'stats':{
			'strength': null,
			'dex': null,
			'con': null,
			'wis': null,
			'char': null
			}
		},
	'animation': null,
	'tavern': {
		'port': null,
		'ip': null,
		'name': null,
		'code': null,
		'id': null,
		'post_number': null,
		},
	'table_id': null,
	'position': null,
	'last_scene': null
	}
	
var api_url = 'https://warlock.tech/api/'
var headers = ["Content-Type: application/json",
				"Authorization: Basic YWRtaW46c3RyaWZlbG9yZA=="]
				
func _ready():
	pass

func make_get_request(request, url):
	request.request(api_url + url, headers, false, HTTPClient.METHOD_GET)
	
func make_post_request(request, url, data):
	var query = JSON.print(data)
	request.request(api_url + url, headers, false, HTTPClient.METHOD_POST, query)
	
func make_patch_request(request, url, data):
	var query = JSON.print(data)
	request.request(api_url + url, headers, false, HTTPClient.METHOD_PATCH, query)
	
func make_delete_request(request, url, data):
	var query = JSON.print(data)
	request.request(api_url + url, headers, false, HTTPClient.METHOD_DELETE, query)

func calc_stat_mod(score):
	if score < 10:
		return (((score - 10) / 2) + 10) - 10
	else:
		return (score - 10) / 2

func distance_to_raise(canvas_node):
	if not is_lower_than_keyboard(canvas_node):
		return 0
	return get_top_of_keyboard_pos() - (canvas_node.get_global_position().y + canvas_node.get_size().y)
	
func is_lower_than_keyboard(ledit):
	if ledit != null and get_top_of_keyboard_pos() != get_viewport().size.y:
		return (ledit.get_global_position().y + ledit.get_size().y) > get_top_of_keyboard_pos()
	return false
	
func get_top_of_keyboard_pos():
	var scale_x = floor(OS.get_window_size().x / get_viewport().size.x)
	var scale_y = floor(OS.get_window_size().y / get_viewport().size.y)
	var screen_scale = max(1, min(scale_x, scale_y))
	if OS.get_virtual_keyboard_height() != 0:
		return get_viewport().size.y - (OS.get_virtual_keyboard_height() / screen_scale)
	return get_viewport().size.y

func remember_me(login):
	var f = File.new()
	f.open("user://login.save", File.READ)
	var json = JSON.parse(f.get_as_text())
	f.close()
	var data = json.result
	data = {"username": login["username"], "password": login["password"], "remember": login["remember"]}
	# Save
	f = File.new()
	f.open("user://login.save", File.WRITE)
	f.store_string(JSON.print(data, "  ", true))
	f.close()
	
func load_login():
	var save_login = File.new()
	save_login.open("user://login.save", File.READ)
	var text = save_login.get_as_text()
	var login = parse_json(text)
	save_login.close()
	return login

func roll(num_of_dice, dice_sides):
	var roll_result = []
	for i in range(0, int(num_of_dice)):
		randomize()
		roll_result.append(randi() % int(dice_sides) + 1)
	return roll_result