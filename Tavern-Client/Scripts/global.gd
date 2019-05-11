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
	'table_id': null
	}
	
var api_url = 'http://localhost:8080/api/'

func _ready():
	pass 
	
func make_post_request(request, url, data, use_ssl):
	var query = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	request.request(api_url + url, headers, use_ssl, HTTPClient.METHOD_POST, query)
	
func make_patch_request(request, url, data, use_ssl):
	var query = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	request.request(api_url + url, headers, use_ssl, HTTPClient.METHOD_PATCH, query)
	
func make_delete_request(request, url, data, use_ssl):
	var query = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	request.request(api_url + url, headers, use_ssl, HTTPClient.METHOD_DELETE, query)