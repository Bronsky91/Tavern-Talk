extends Node

class_name Commands

onready var table = get_parent()

var command_dict: Dictionary = {
	'w': 'Whisper something to another patron at the table, careful though it may not be as secret as you think. /w patronname',
	'throw':  'Shortcut command to throw an object, /throw object_name to execute',
	'e': 'Emote, type out what you would like your character to do as an action, no need to type your name',
	'eb': 'Same as Emote, but will broadcast your action to the whole tavern',
	'yell': 'Yell something, the tavern will all hear it',
	'armwrestle': 'Challenge another patron at the table to an arm wrestle, /armwrestle patron_name to execute',
	'cointoss': 'flips a coin, resulting in heads or tails'
}

func help(params: PoolStringArray):
	var cmd: String = params[0]
	if cmd in table.chat_commands:
		table.send_system_message(get_tree().get_network_unique_id(), cmd + " - "+ command_dict[cmd])
	else:
		var cmd_list = "Type /help and any command name to find out more.\n\n"
		for command in command_dict:
			cmd_list += command + "\n"
		table.send_system_message(get_tree().get_network_unique_id(), cmd_list)

func w(params: PoolStringArray):
	var recipient: String = params[0]
	params.remove(0)
	var msg = params.join(" ")
	var r_id = null
	for patron in table.get_current_patrons():
		if patron.name.to_lower().findn(recipient.to_lower()) != -1:
			r_id = patron.id
			recipient = patron.name
	if r_id != null:
		## Send Whisper
		table.get_node("ChatInput").text = ""
		table.rpc("receive_whisper", get_tree().get_network_unique_id(), r_id, g.player_data.character.name, recipient.capitalize(), msg)
	else:
		table.send_system_message(get_tree().get_network_unique_id(), "That patron isn't at table")

func throw(params: PoolStringArray):
	var strength: int = g.player_data.character.stats.strength
	var dex: int = g.player_data.character.stats.dex
	var object: String = params.join(" ")
	var msg: String
	if strength > 14:
		msg = "throws "+ ("his " if g.player_data.character.gender == "Male" else "her ")+object+ " across the room hitting the wall with a loud thud."
	elif dex > 14:
		msg = "throws "+ ("his " if g.player_data.character.gender == "Male" else "her ")+object+ ", narrowly missing "+table.find_random_patron().name
	else:
		msg = "throws "+ ("his " if g.player_data.character.gender == "Male" else "her ")+object+ ", the barmaid yells, \"You're weak!\""
	table.send_broadcast(msg)
	
func e(params: PoolStringArray):
	## Custom emote function
	var msg: String = params.join(" ")
	table.send_action_message(msg)
	
func eb(params: PoolStringArray):
	## Custom emote broadcast function
	var msg: String = params.join(" ")
	table.send_broadcast(msg)
	
func yell(params: PoolStringArray):
	var msg = params.join(" ")
	msg = " yells, "+"\""+msg+"\""
	table.send_broadcast(msg)
	
func armwrestle(params: PoolStringArray):
	var challenger: Patron = table.find_patron_by_name(params[0])
	var initiator: Patron = table.find_patron_by_name(table.character_name)
	if challenger.name == initiator.name: 
		table.send_system_message(initiator.id, "Can't armwrestle yourself, sorry!")
	else:
		var c_obj: Dictionary = {'id': challenger.id, 'name': challenger.name, 'mod': g.calc_stat_mod(challenger.stats.strength)}
		var i_obj: Dictionary = {'id': initiator.id, 'name': initiator.name, 'mod': g.calc_stat_mod(initiator.stats.strength)}
		table.rpc_id(challenger.id, "ask_for_aw", i_obj, c_obj)

func roll(params: PoolStringArray) -> void:
	var roll_string: String = params.join(" ")
	var roll: PoolStringArray = roll_string.split("d")
	var result: Array
	var msg = ""
	if len(roll[0]) == 0:
		result = g.roll(1, roll[1])
		msg = "rolls a d"+roll[1]+" and gets "+str(result[0])
	else:
		result = g.roll(roll[0], roll[1])
		var s_result = ""
		for i in result.size():
			if i == result.size() - 1:
				s_result = s_result +" and "+ str(result[i]) +'.'
			else:
				s_result = s_result + str(result[i]) +', '
		msg = "rolls "+roll[0]+" d"+roll[1]+"'s and gets "+s_result
	table.send_action_message(msg)
	
func cointoss(params: PoolStringArray) -> void:
	var msg: String
	randomize()
	var coin = randi() % 2
	print(coin)
	if coin == 0:
		msg = "flips a coin and it lands on Heads!"
	else:
		msg = "flips a coin and it lands on Tails!"
	table.send_action_message(msg)
	