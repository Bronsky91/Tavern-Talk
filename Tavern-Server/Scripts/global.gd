extends Node

var player_data = {
	'user_id': null,
	'character': {
		'id': null,
		'name': null,
		'animation': {'current': null, 'sat_down': false},
		},
	'tavern': {
		'port': null,
		'ip': null,
		'name': null,
		'code': null,
		'id': null
		},
	'table_id': null,
	'position': null
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
