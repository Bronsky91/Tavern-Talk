extends Node2D

onready var chat_display = $ChatDisplay
onready var chat_input = $ChatInput

var character_name = global.player_data.character.name
var table_id = null
var current_patrons = []

class SortPatronNames:
	static func sort(a, b):
		if a.name < b.name:
			return true
		return false

func assign(_table_id):
	table_id = _table_id

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")

sync func receive_message(c_name, msg):
	if msg.length() > 0:
		chat_display.text += c_name + ": " + msg + "\n"

sync func receive_action_message(c_name, msg):
		chat_display.text += c_name + " " + msg + "\n"

sync func set_current_patrons(id, patron_name):
	var patron = {'id': id, 'name': patron_name}
	current_patrons.append(patron)
	current_patrons.sort_custom(SortPatronNames, "sort")
	$PatronList.add_item(patron.name)
	$PatronList.sort_items_by_text()

sync func remove_patron(id):
	print(id)
	var patron_that_left
	for i in current_patrons.size():
		print(current_patrons)
		if current_patrons[i].id == id:
			current_patrons.remove(i)
			patron_that_left = i
			break
	$PatronList.remove_item(patron_that_left)
	
func _on_Leave_button_up():
	.hide()
	var patron_that_left
	for i in current_patrons.size():
		if current_patrons[i].name == character_name:
			current_patrons.remove(i)
			patron_that_left = i
	$PatronList.remove_item(patron_that_left)
