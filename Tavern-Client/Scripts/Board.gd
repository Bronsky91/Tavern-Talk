extends Node2D

export(PackedScene) var post_scene

onready var animate = $AnimationPlayer

var avail_post_count = 25
var post_dict = {}

func _ready():
	create_post_dict()
	g.make_get_request($Board/BoardRequest, 'tavern/' + g.player_data.tavern.id + '/board')

func create_post_dict():
	for i in range(avail_post_count):
		post_dict[i] = null
		
func populate_posts(posts):
	## Populates post_dic with the _ids of all posts
	var post_num = 0
	for post in posts:
		post_dict[post_num] = post
		post_num = post_num + 1
		
	for key in post_dict:
		var current_post_button = get_node("Board/BulletinBoard_Wallpaper/BulletinBoardBG/TextureButton" + str(key+1))
		if post_dict[key] != null: ## if the post isn't null, populate it on the board
			current_post_button.disabled = false
			current_post_button.visible = true
		elif post_dict[key] == null:
			current_post_button.disabled = true
			current_post_button.visible = false

func takedown_post(id):
	for key in post_dict:
		if post_dict[key] != null and post_dict[key]['_id'] == id:
			post_dict[key] = null
	
func _on_BoardRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var posts = json.result.data
	populate_posts(posts)

func _on_NewPost_button_up():
	var new_post = post_scene.instance()
	new_post.new_post(true)
	add_child(new_post)
	
func _on_BackButton_button_up():
	get_parent().update_board_texture()
	get_node("/root/Tavern/YSort/"+str(get_tree().get_network_unique_id())).busy = false
	hide()
	
func _notification(notif):
	if notif == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST or notif == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_parent().update_board_texture()
		get_node("/root/Tavern/YSort/"+str(get_tree().get_network_unique_id())).busy = false
		if get_node_or_null("Post") != null:
			get_node("Post").queue_free()
		else:
			hide()
		
func _on_TextureButton_button_up(num):
	var post_data = post_dict[num]
	var new_post = post_scene.instance()
	add_child(new_post)
	new_post.new_post(false, post_data._id, post_data.body, post_data.author)

func _on_BoardScene_visibility_changed():
	if visible == true:
		get_node("/root/Tavern/YSort/"+str(get_tree().get_network_unique_id())).busy = true

func _on_RightArrow_button_up():
	if $Board/BulletinBoard_Wallpaper/BulletinBoardBG.position.x == 0:
		animate.play("BoardShiftRight")
	if $Board/BulletinBoard_Wallpaper/BulletinBoardBG.position.x == 360:
		animate.play_backwards("BoardShiftLeft")

func _on_LeftArrow_button_up():
	if $Board/BulletinBoard_Wallpaper/BulletinBoardBG.position.x == 0:
		animate.play("BoardShiftLeft")
	if $Board/BulletinBoard_Wallpaper/BulletinBoardBG.position.x == -360:
		animate.play_backwards("BoardShiftRight")

func _on_AnimationPlayer_animation_finished(anim_name):
	if $Board/BulletinBoard_Wallpaper/BulletinBoardBG.position.x == 0:
		$Board/RightArrow.show()
		$Board/LeftArrow.show()
	if $Board/BulletinBoard_Wallpaper/BulletinBoardBG.position.x == 360:
		$Board/LeftArrow.hide()
	if $Board/BulletinBoard_Wallpaper/BulletinBoardBG.position.x == -360:
		$Board/RightArrow.hide()
