extends Control

onready var menu = get_parent()
onready var email = $EmailLabel/Email
onready var username = $UsernameLabel/Username
onready var password = $PasswordLabel/Password
onready var confirm = $ConfirmLabel/Confirm

func _ready():
	pass

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	## TODO:
	# Handle if there is a user with the email/username already
	if response_code == 500:
		return
	else:
		var json = JSON.parse(body.get_string_from_utf8())
		global.user_id = json.result.id
		hide()
		menu.change_menu_scene(self, menu.get_node("CharacterSelect"))

func _on_Sign_Up_button_up():
	if (email.text != "" and
	 username.text != "" and
	 password.text != "" and
	 confirm.text  != "" and
	 password.text == confirm.text):
		## TODO:
		# Add field validation
		var data = {"email": email.text, "username": username.text, "password": password.text}
		global.make_post_request($HTTPRequest, 'users', data)

func _on_Back_button_up():
	menu.change_menu_scene(self, menu.get_node("Login"))
