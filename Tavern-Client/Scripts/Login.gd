extends Control

onready var menu = get_parent()
onready var username = $UsernameLabel/Username
onready var password = $PasswordLabel/Password


func _ready():
	get_tree().set_auto_accept_quit(true)
	
func _process(delta):
	if g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = g.distance_to_raise(get_focus_owner())
	elif OS.get_virtual_keyboard_height() == 0 and not g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = 0
	
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
	