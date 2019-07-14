extends Node2D

class_name Post

onready var post_body: Label = $Body
onready var post_author: Label = $Body/Author

var new_post: bool = false
var post_limit: int = 359
var post_id: String = '0'
var author_input_y_pos: int

func _enter_tree():
	author_input_y_pos = $AuthorEdit.rect_position.y
	if not new_post:
		$NewEdit.text = "Edit"
	else:
		$Remove.hide()

func _input(event):
	if Input.is_action_just_pressed('backspace') and $BodyEdit.cursor_get_line() > 0:
		$BodyEdit.readonly = false
	
func _process(delta):
	raise_text_edit($AuthorEdit, author_input_y_pos)
	
func raise_text_edit(input: Label, input_y_pos: int) -> void:
	if input.has_focus() and OS.get_virtual_keyboard_height() > 0:
		input.rect_position.y = g.get_top_of_keyboard_pos() - input.get_size().y
	else:
		input.rect_position.y = input_y_pos
		
func new_post(new: bool, id: String = '', body: String = '', author: String = '') -> void:
	## Called from Board before post scene is added to scene_tree
	if new:
		new_post = true
		$BodyEdit.show()
		$AuthorEdit.show()
		$NewEdit.text = 'Post'
	else:
		new_post = false
		post_id = id
		$BodyEdit.hide()
		$AuthorEdit.hide()
		write_post(body, author)

func write_post(body: String, author: String) -> void:
	post_body.text = body
	post_author.text = author
	$Limit.text = "Character Limit " + str(post_body.text.length()) + "/358"
	
func _on_TextEdit_text_changed():
	$Limit.text = "Character Limit " + str($BodyEdit.text.length()) + "/358"
	if $BodyEdit.text.length() > 357:
		$Limit.add_color_override("font_color", Color(1, 0, 0))
	else:
		$Limit.add_color_override("font_color", Color(0, 0, 0))

func _on_NewEdit_button_up():
	## TODO: Save post on current board view
	## TODO: Prevent saving more posts than there are slots on the board
	if new_post && $BodyEdit.text.length() < post_limit:
		write_post($BodyEdit.text, $AuthorEdit.text)
		hide_edit(true)
		new_post = false
		$NewEdit.text = 'Edit'
		## Conditional to check post_id
		if post_id == '0':
			var data: Dictionary = {'board': {"body": $BodyEdit.text, "author": $AuthorEdit.text}}
			g.make_patch_request($PostSave, 'tavern/' + g.player_data.tavern.id, data)
		else:
			var data: Dictionary = {"id": post_id, "body": $BodyEdit.text, "author": $AuthorEdit.text}
			g.make_patch_request($PostSave, 'tavern/' + g.player_data.tavern.id + '/board', data)
	else:
		hide_edit(false)
		$NewEdit.text = 'Post'
		new_post = true

func hide_edit(hide: bool) -> void:
	if hide:
		$BodyEdit.hide()
		$AuthorEdit.hide()
		post_body.show()
		post_author.show()
	else:
		$BodyEdit.show()
		$BodyEdit.text = post_body.text
		$AuthorEdit.show()
		$AuthorEdit.text = post_author.text
		post_body.hide()
		post_author.hide()
		
func _on_Return_button_up():
	queue_free()
	
func _on_PostSave_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	g.make_get_request(get_node("/root/Tavern/BoardScene/Board/BoardRequest"), 'tavern/' + g.player_data.tavern.id + '/board')
	## Display error if post did not save for some reason

func _on_Remove_button_up():
	var data = {'_id': post_id}
	g.make_delete_request($PostRemove, 'tavern/' + g.player_data.tavern.id + '/board', data)
	## TODO: Confirmation Check

func _on_PostRemove_request_completed(result, response_code, headers, body):
	get_parent().takedown_post(post_id)
	g.make_get_request(get_node("/root/Tavern/BoardScene/Board/BoardRequest"), 'tavern/' + g.player_data.tavern.id + '/board')
	call_deferred("free")
