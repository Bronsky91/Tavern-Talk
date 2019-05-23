extends Control

onready var username = $UsernameLabel/Username
onready var password = $PasswordLabel/Password

func _ready():
	pass
	
func make_post_request(url, data, use_ssl):
	var query = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 401:
		return
	else:
		var json = JSON.parse(body.get_string_from_utf8())
		global.player_data.user_id = json.result.id
		get_tree().change_scene("Scenes/CharacterSelect.tscn")

func login():
	var data = {'username': username.text, 'password': password.text}
	## TODO
	# username and password validation and security
	global.make_post_request($HTTPRequest, 'login', data, false)

func _on_Register_button_up():
	get_tree().change_scene("Scenes/Register.tscn")