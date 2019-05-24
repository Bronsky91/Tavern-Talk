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
	'position': null
	}
	
var api_url = 'http://localhost:8080/api/'

func _ready():
	pass 
	
func make_get_request(request, url, use_ssl):
	var headers = ["Content-Type: application/json"]
	request.request(api_url + url, headers, use_ssl, HTTPClient.METHOD_GET)
	
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

func calc_stat_mod(score):
	if score < 10:
		return (((score - 10) / 2) + 10) - 10
	else:
		return (score - 10) / 2
		