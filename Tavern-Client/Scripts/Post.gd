extends Node2D

onready var post_body = $Body
onready var post_author = $Body/Author

var new_post = false
var post_limit = 359
var post_id = '0'

func _ready():
	## May need to change to _enter_tree
	if not new_post:
		$Limit.text = "Character Limit " + str($BodyEdit.text.length()) + "/358"
		$NewEdit.text = "Edit"

func _input(event):
	if Input.is_action_just_pressed('backspace') and $BodyEdit.cursor_get_line() > 0:
		$BodyEdit.readonly = false
	
func new_post(new, id, body, author):
	## Called from Board before post scene is added to scene_tree
	if new:
		new_post = true
		hide_edit(false)
		$NewEdit.text = 'Post'
	else:
		post_id = id
		write_post(body, author)

func write_post(body, author):
	print(post_body)
	post_body.text = body
	post_author.text = author
	
func _on_TextEdit_text_changed():
	$Limit.text = "Character Limit " + str($BodyEdit.text.length()) + "/358"
	if $BodyEdit.text.length() > 357:
		$Limit.add_color_override("font_color", Color(1, 0, 0))
	else:
		$Limit.add_color_override("font_color", Color(0, 0, 0))

func _on_NewEdit_button_up():
	if new_post && $BodyEdit.text.length() < post_limit:
		write_post($BodyEdit.text, $AuthorEdit.text)
		hide_edit(true)
		new_post = false
		$NewEdit.text = 'Edit'
		var post_data = {'id': post_id, 'body': $BodyEdit.text, 'author': $AuthorEdit.text}
		### TODO: Add logic to API that if id == '0', it's a new post otherwise edit it properly
		print('tavern/' + global.player_data.tavern.id + '/board')
		print(post_data)
		global.make_post_request($PostSave, 'tavern/' + global.player_data.tavern.id + '/board', post_data, false)
	else:
		hide_edit(false)
		$NewEdit.text = 'Post'
		new_post = true

func hide_edit(hide):
	if hide:
		$BodyEdit.hide()
		$AuthorEdit.hide()
	else:
		$BodyEdit.show()
		$BodyEdit.text = post_body.text
		$AuthorEdit.show()
		$AuthorEdit.text = post_author.text
	
func _on_Return_button_up():
	get_parent().find_node("Board").show()
	queue_free()
	
func _on_PostSave_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	## Display error if post did not save for some reason


