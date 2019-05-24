extends Node

onready var table = get_parent()

sync func whisper(params):
	print(params)
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
		
func throw(params):
	print(params)
	var strength = global.player_data.character.stats.strength
	var dex = global.player_data.character.stats.dex
	var object = params[0]
	var msg = ""
	if strength > 12:
		msg = "throws "+ ("his " if global.player_data.character.gender == "Male" else "her ")+object+ " across the room hitting the wall with a loud thud."
	elif dex > 14:
		msg = "throws their "+object+ ", narrowly missing "+table.find_random_patron().name
	else:
		msg = "throws their "+object+ ", the barmaid yells, \"You're weak!\""
	print(msg)
	table.send_broadcast(msg)
	
func e(params):
	## Custom emote function
	var msg = params.join(" ")
	table.send_action_message(msg)
	
func eb(params):
	## Custom emote broadcast function
	var msg = params.join(" ")
	table.send_broadcast(msg)
	
func yell(params):
	var msg = params.join(" ")
	msg = " yells, "+"\""+msg+"\""
	table.send_broadcast(msg)
	
func armwrestle(params):
	var challenger = table.find_patron_by_name(params[0])
	var initiator = table.find_patron_by_name(table.character_name)
	if challenger.name == initiator.name:
		pass
		## TODO: system message saying the player must choose someone other themselves
	else:
		var c_obj = {'id': challenger.id, 'name': challenger.name, 'mod': global.calc_stat_mod(challenger.stats.strength)}
		var i_obj = {'id': initiator.id, 'name': initiator.name, 'mod': global.calc_stat_mod(initiator.stats.strength)}
		table.rpc("ask_for_aw", i_obj, c_obj)
	## display popup for acceptance of challengers screen and popup for waiting on initiator's screen
	## Once accepted the armwrestle scene is shown
	#### Make a sync function in table script for displaying the armwrestle scene over the table for each player
	#### called from this command