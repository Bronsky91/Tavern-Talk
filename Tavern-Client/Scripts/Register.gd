extends Control

onready var menu: MainMenu = get_parent()
onready var email: LineEdit = $EmailLabel/Email
onready var username: LineEdit = $UsernameLabel/Username
onready var password: LineEdit = $PasswordLabel/Password
onready var confirm: LineEdit = $ConfirmLabel/Confirm

func _ready():
	get_tree().set_auto_accept_quit(false)
	
func _process(delta):
	if g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = g.distance_to_raise(get_focus_owner())
	elif OS.get_virtual_keyboard_height() == 0 and not g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = 0
		
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	## TODO:
	# Handle if there is a user with the email/username already
	if response_code == 500:
		return
	else:
		var json = JSON.parse(body.get_string_from_utf8())
		g.player_data.user_id = json.result.data._id
		hide()
		menu.change_menu_scene(self, menu.get_node("CharacterSelect"))

func _on_Sign_Up_button_up() -> void:
	if (email.text != "" and
	 username.text != "" and
	 password.text != "" and
	 confirm.text  != "" and
	 password.text == confirm.text):
		if " " in username.text:
			$Error.text =  "Invalid Username, remove spaces"
		elif " " in password.text:
			$Error.text =  "Invalid Password, remove spaces"
		else:
			var data = {"email": email.text, "username": username.text.to_lower(), "password": password.text}
			g.make_post_request($HTTPRequest, 'users', data)

func _on_Back_button_up():
	menu.change_menu_scene(self, menu.get_node("Login"))


