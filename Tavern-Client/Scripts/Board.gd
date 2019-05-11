extends Node2D

export(PackedScene) var post_scene
onready var post_buttons = [
 $Board/TextureButton1, $Board/TextureButton2, $Board/TextureButton3, $Board/TextureButton4,
 $Board/TextureButton5, $Board/TextureButton6, $Board/TextureButton7, $Board/TextureButton8
]
var post_dict = {1: null, 2: null, 3: null, 4: null, 5: null, 6: null, 7: null, 8: null}

func _ready():
	## TEMP FOR DEBUG
	global.player_data.tavern.id = "5cbf609bcfa4e90275f81e4c"
	###
	$Board/BoardRequest.request(global.api_url + 'tavern/' + global.player_data.tavern.id + '/board')
	
func populate_posts(posts):
	## Populates post_dic with the _ids of all posts
	var post_num = 0
	for post in posts:
		post_dict[post_num] = post
		post_num = post_num + 1

	for key in post_dict:
		if post_dict[key] != null: ## if the post isn't null, populate it on the board
			print(post_buttons)
			post_buttons[key].disabled = false
			post_buttons[key].visible = true

	
func _on_BoardRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	var posts = json.result.data
	populate_posts(posts)

func _on_NewPost_button_up():
	var new_post = post_scene.instance()
	new_post.new_post(true)
	$Board.hide()
	add_child(new_post)
	
func _on_BackButton_button_up():
	get_tree().change_scene("Scenes/Tavern.tscn")

func _on_TextureButton_button_up(num):
	var post_data = post_dict[num]
	var new_post = post_scene.instance()
	add_child(new_post)
	new_post.new_post(false, post_data._id, post_data.body, post_data.author)
	$Board.hide()
	
func _on_Board_visibility_changed():
	## TEMP FOR DEBUG
	global.player_data.tavern.id = "5cbf609bcfa4e90275f81e4c"
	###
	if $Board.visible == true:
		$Board/BoardRequest.request(global.api_url + 'tavern/' + global.player_data.tavern.id + '/board')