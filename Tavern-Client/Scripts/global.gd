extends Node

var player_data = {
	'user_id': null,
	'character': {
		'id': null,
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
	'tavern': {
		'port': null,
		'ip': null,
		'name': null,
		'code': null,
		'id': null
		},
	'table_id': null,
	'position': null,
	'last_scene': null
	}
	
var api_url = 'https://warlock.tech/api/'
var headers = ["Content-Type: application/json",
				"Authorization: Basic YWRtaW46c3RyaWZlbG9yZA=="]
				
var screen_scale

onready var viewport = get_viewport()

func _ready():
	var window_size = OS.get_window_size()
	var scale_x = floor(window_size.x / viewport.size.x)
	var scale_y = floor(window_size.y / viewport.size.y)
	screen_scale = max(1, min(scale_x, scale_y))

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

func is_lower_than_keyboard(ledit):
	return ledit.get_global_position().y < get_keyboard_height()

func get_keyboard_height():
	return OS.get_virtual_keyboard_height() / screen_scale