extends Node2D

export(PackedScene) var post

var post_list = []

func _ready():
	$BoardRequest.request(global.api_url + 'tavern/' + global.player_data.tavern.id + '/board')
	
func populate_posts(posts):
	# Only populate posts that aren't already on the board
	for post in post_list:
		for p in posts:
			if post._id == p._id:
				posts.erase(p)
	# Instance all remaining posts
	for p in posts:
		var new_post = post.instance()
		new_post.new_post(false, p._id, p.body, p.author)
		post_list.append(new_post)
		$GridContainer.add_child(post)
		## TODO: Adjust size of each post or use placeholder image
		## Maybe use placeholder and attach the post ID to each placeholder?

func create_post():
	var new_post = post.instance()
	new_post.new_post(true)
	## Change scene to post scene?
	
func _on_BoardRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var posts = json.result.data
	populate_posts(posts)

func _on_NewPost_button_up():
	get_tree().change_scene("Scenes/Post.tscn")
