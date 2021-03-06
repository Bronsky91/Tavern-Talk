extends Control

onready var menu: MainMenu = get_parent()
onready var username: LineEdit = $UsernameLabel/Username
onready var password: LineEdit = $PasswordLabel/Password
onready var remember_me: CheckBox = $CheckBox

var login: Dictionary

func _ready():
	login = g.load_login()
	
func _process(delta):
	if g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = g.distance_to_raise(get_focus_owner())
	elif OS.get_virtual_keyboard_height() == 0 and not g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = 0

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
	if response_code == 401:
		$Error.text = json.result.message
	else:
		g.player_data.user_id = json.result._id
		if remember_me.pressed:
			g.remember_me({'username': json.result.username, 'password': password.text, 'remember': true})
		else:
			g.remember_me({'username': null, 'password': null, 'remember': false})
		menu.change_menu_scene(self, menu.get_node("CharacterSelect"))

func login() -> void:
	username.text = username.text.trim_suffix(" ")
	username.text = username.text.trim_prefix(" ")
	var data: Dictionary = {'username': username.text.to_lower(), 'password': password.text}
	g.make_post_request($HTTPRequest, 'login', data)

func _on_Register_button_up():
	menu.change_menu_scene(self, menu.get_node("Register"))
	
func _on_Login_visibility_changed():
	if visible:
		if login != null and login.remember:
			username.text = login.username
			password.text = login.password
		elif login != null:
			$CheckBox.pressed = login.remember