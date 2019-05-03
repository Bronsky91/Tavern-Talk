extends Control

onready var invite_code = $Invite/InviteCode
onready var new_tavern_name = $Create/NewTavern

func _on_EnterTavern_button_up():
	var data = {"code": invite_code.text}
	global.make_post_request($HTTPRequestEnter, 'tavern/enter', data, false)

func _on_CreateTavern_button_up():
	var data = {
		'name': new_tavern_name.text,
		'character': {
			'user_id': global.player_data.user_id,
			'character_d': global.player_data.character.id,
			'table': 0
			}
		}
	global.make_post_request($HTTPRequestCreate, 'tavern/taverns', data, false)

func _on_HTTPRequestCreate_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var data = json.result.data
	## TODO: Make check to see if tavern was created
	global.player_data.tavern = {
		'port': data.port,
		'ip': data.ip,
		'name': data.name,
		'code': data.code,
		'id': data._id
		}
	global.player_data.table_id = 0
	get_tree().change_scene("Scenes/Tavern.tscn")

func _on_HTTPRequestEnter_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		var data = json.result.data
		global.player_data.tavern = {
			'port': data.port,
			'ip': data.ip,
			'name': data.name,
			'code': data.code,
			'id': data._id
		}
		global.player_data.table_id = 0
		get_tree().change_scene('Scenes/Tavern.tscn')
