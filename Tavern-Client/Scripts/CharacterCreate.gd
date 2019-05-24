extends Control

onready var menu = get_parent()
onready var character_name = $NameLabel/Name
onready var gender_list = $GenderLabel/Gender
onready var stat_tree = $Stats/Tree

# Stats tree vars
var strength = null
var dex = null
var con = null
var wis = null
var cha = null

var gender = ""

func _ready():
	gender_list.add_item("Male")
	gender_list.add_item("Female")
	
	var root = stat_tree.create_item()
	root.set_text(0, "Stats:")
	root.set_text(1, "Score:")
	
	strength = stat_tree.create_item(root)
	strength.set_text(0, "STR")
	strength.set_editable(1, true)
	strength.set_cell_mode(1, 2)
	strength.set_range_config ( 1, 1, 22, 1)
	strength.set_range (1, 10)
	
	dex = stat_tree.create_item(root)
	dex.set_text(0, "DEX")
	dex.set_editable(1,true)
	dex.set_cell_mode(1, 2)
	dex.set_range_config ( 1, 1, 22, 1)
	dex.set_range (1, 10)
	
	con = stat_tree.create_item(root)
	con.set_text(0, "CON")
	con.set_editable(1,true)
	con.set_cell_mode(1, 2)
	con.set_range_config ( 1, 1, 22, 1)
	con.set_range (1, 10)
	
	wis = stat_tree.create_item(root)
	wis.set_text(0, "WIS")
	wis.set_editable(1,true)
	wis.set_cell_mode(1, 2)
	wis.set_range_config ( 1, 1, 22, 1)
	wis.set_range (1, 10)
	
	cha = stat_tree.create_item(root)
	cha.set_text(0, "CHA")
	cha.set_editable(1,true)
	cha.set_cell_mode(1, 2)
	cha.set_range_config ( 1, 1, 22, 1)
	cha.set_range (1, 10)

func _on_Create_request_completed(result, response_code, headers, body):
	if response_code == 200:
		menu.change_menu_scene(self, menu.get_node('CharacterSelect'))

func _on_CreateButton_button_up():
	var data = {
		"characters": {
			"name": character_name.text,
			"gender": gender,
			"stats":{
				"strength": strength.get_range(1),
				"dex": dex.get_range(1),
				"con": con.get_range(1),
				"wis": wis.get_range(1),
				"cha": cha.get_range(1)
			}
		}
	}
	global.make_patch_request($Create, 'users/' + global.player_data.user_id, data, false)

func _on_Back_button_up():
	menu.change_menu_scene(self, menu.get_node('CharacterSelect'))

func _on_Gender_item_selected(index):
	gender = gender_list.get_item_text(index)
