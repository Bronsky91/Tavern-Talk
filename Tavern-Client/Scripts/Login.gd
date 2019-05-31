extends Control

onready var menu = get_parent()
onready var username = $UsernameLabel/Username
onready var password = $PasswordLabel/Password

var keyboard_found = false

func _ready():
	get_tree().set_auto_accept_quit(true)

func _process(delta):
	if not keyboard_found and $PasswordLabel/Password.has_focus() and g.is_lower_than_keyboard($PasswordLabel/Password):
		keyboard_found=true
		get_parent().position.y = ((g.get_keyboard_height() - ($PasswordLabel/Password.get_global_position().y + $PasswordLabel/Password.get_size().y)) * g.screen_scale)
	elif not get_parent().position.y == 0 and g.get_keyboard_height() == 0:
		get_parent().position.y = 0
		keyboard_found=false
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print(response_code)
	$Error.text = str(result)
	if response_code == 401:
		$Error.text = "Incorrect Login"
		## TODO Specify
	else:
		var json = JSON.parse(body.get_string_from_utf8())
		print(response_code)
		g.player_data.user_id = json.result._id
		menu.change_menu_scene(self, menu.get_node("CharacterSelect"))

func login():
	var data = {'username': username.text, 'password': password.text}
	## TODO
	# username and password validation and security
	g.make_post_request($HTTPRequest, 'login', data)

func _on_Register_button_up():
	menu.change_menu_scene(self, menu.get_node("Register"))
	