extends Node

var player_data = {
	'user_id': null,
	'character': {
		'id': null,
		'name': null,
		## More stats
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
	
var api_url = 'https://localhost:8080/api/'

func _ready():
	pass 
	
func make_post_request(request, url, data):
	var query = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	request.request(api_url + url, headers, false, HTTPClient.METHOD_POST, query)