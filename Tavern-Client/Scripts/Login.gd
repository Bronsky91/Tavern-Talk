extends Control

onready var menu = get_parent()
onready var username = $UsernameLabel/Username
onready var password = $PasswordLabel/Password

func _ready():
	pass

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print(response_code)
	if response_code == 401:
		return
		## TODO add error message for incorrect login
	else:
		var json = JSON.parse(body.get_string_from_utf8())
		print(response_code)
		global.player_data.user_id = json.result.id
		menu.change_menu_scene(self, menu.get_node("CharacterSelect"))

func login():
	var data = {'username': username.text, 'password': password.text}
	## TODO
	# username and password validation and security
	global.make_post_request($HTTPRequest, 'login', data)

func _on_Register_button_up():
	menu.change_menu_scene(self, menu.get_node("Register"))