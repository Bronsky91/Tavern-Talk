extends Node

onready var table = get_parent()

sync func whisper(params):
	var recipient = params[0]
	params.remove(0)
	var msg = params.join(" ")
	var r_id = null
	for patron in table.get_current_patrons():
		if patron.name.to_lower() == recipient.to_lower():
			r_id = patron.id
	if r_id != null:
		## Send whisper
		table.get_node("ChatInput").text = ""
		table.rpc("receive_whisper", get_tree().get_network_unique_id(), r_id, global.player_data.character.name, recipient.capitalize(), msg)
	else:
		## TODO: Error message for not finding patron
		print("patron not found")