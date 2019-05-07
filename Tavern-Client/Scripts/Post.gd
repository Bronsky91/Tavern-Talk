extends Node2D

onready var post_body = $Body
onready var post_author = $Body/Author

var new_post = false
var post_limit = 359
var post_id = '0'

func _ready():
	if not new_post:
		$Limit.text = "Character Limit " + str($BodyEdit.text.length()) + "/358"
		$NewEdit.text = "Edit"

func _input(event):
	if Input.is_action_just_pressed('backspace') and $BodyEdit.cursor_get_line() > 0:
		$BodyEdit.readonly = false
	
func new_post(new, id=null, body=null, author=null):
	## Called from Board before post scene is added to scene_tree
	if new:
		new_post = true
		hide_edit(false)
		$NewEdit.text = 'Post'
	else:
		post_id = id
		write_post(body, author)

func write_post(body, author):
	post_body.text = body
	post_author = "- " + author
	
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
		# var post_data = {id: post_id, body: $BodyEdit.text, author: $AuthorEdit.text}
		### TODO: Add logic to API that if id == '0', it's a new post otherwise edit it properly
		# global.make_post_request($PostSave, 'save_post', post_data, false)
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
		$AuthorEdit.show()
	
func _on_Return_button_up():
	get_tree().change_scene("Scenes/Board.tscn")
	
func _on_PostSave_request_completed(result, response_code, headers, body):
	pass # Replace with function body.
	## Display error if post did not save for some reason


