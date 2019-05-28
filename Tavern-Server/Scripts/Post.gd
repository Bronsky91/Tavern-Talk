extends Node2D

onready var post_body = $Body
onready var post_author = $Body/Author

var new_post = false
var post_limit = 359
var post_id = '0'

func _enter_tree():
	## May need to change to _enter_tree
	if not new_post:
		$NewEdit.text = "Edit"
	else:
		$Remove.hide()

func _input(event):
	if Input.is_action_just_pressed('backspace') and $BodyEdit.cursor_get_line() > 0:
		$BodyEdit.readonly = false
	
func new_post(new, id='', body='', author=''):
	## Called from Board before post scene is added to scene_tree
	if new:
		new_post = true
		$BodyEdit.show()
		$AuthorEdit.show()
		$NewEdit.text = 'Post'
	else:
		post_id = id
		write_post(body, author)

func write_post(body, author):
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
	if new_post && $BodyEdit.text.length() < post_limit:
		write_post($BodyEdit.text, $AuthorEdit.text)
		hide_edit(true)
		new_post = false
		$NewEdit.text = 'Edit'
		## Conditional to check post_id
		if post_id == '0':
			var data = {'board': {"body": $BodyEdit.text, "author": $AuthorEdit.text}}
			global.make_patch_request($PostSave, 'tavern/' + global.player_data.tavern.id, data)
		else:
			var data = {"id": post_id, "body": $BodyEdit.text, "author": $AuthorEdit.text}
			global.make_patch_request($PostSave, 'tavern/' + global.player_data.tavern.id + '/board', data)
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

func _on_Remove_button_up():
	var data = {'_id': post_id}
	global.make_delete_request($PostRemove, 'tavern/' + global.player_data.tavern.id + '/board', data)
	## TODO: Confirmation Check

func _on_PostRemove_request_completed(result, response_code, headers, body):
	get_parent().takedown_post(post_id)
	get_parent().find_node("Board").show()
	call_deferred("free")
