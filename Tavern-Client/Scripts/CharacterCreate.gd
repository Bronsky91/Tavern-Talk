extends Control

onready var menu = get_parent()
onready var character_name = $Step1/NameLabel/Name
onready var gender_list = $Step1/GenderLabel/Gender
onready var stat_tree = $Step1/Stats/Tree
onready var animate = $Step2/Body/AnimationPlayer

# Stats tree vars
var strength = null
var dex = null
var con = null
var wis = null
var cha = null

var gender = ""
var skin = 1
var hair = 1
var eyes = 1
var clothes = 1

var character_data = {}

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
	character_data = {
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
	$Step1.visible = false
	$Step2.visible = true
	

func _on_Back_button_up():
	menu.change_menu_scene(self, menu.get_node('CharacterSelect'))

func _on_Gender_item_selected(index):
	gender = gender_list.get_item_text(index)

func _on_Step2_visibility_changed():
	if $Step2.visible == true:
		
		$Step2/Body.set_texture(load("res://Assets/Characters/"+gender+"_Idle_00"+str(skin)+".png"))
		$Step2/Body/Hair.set_texture(load("res://Assets/Characters/"+gender+"_IdleHair_00"+str(hair)+".png"))
		$Step2/Body/Eyes.set_texture(load("res://Assets/Characters/"+gender+"_IdleEyes_00"+str(eyes)+".png"))
		$Step2/Body/Clothes.set_texture(load("res://Assets/Characters/"+gender+"_IdleClothes_00"+str(clothes)+".png"))
		animate.current_animation = "idle_down"

func _on_Skin_button_up():
	if skin < 3:
		skin += 1
		$Step2/Body.set_texture(load("res://Assets/Characters/"+gender+"_Idle_00"+str(skin)+".png"))
	else:
		skin = 1
		$Step2/Body.set_texture(load("res://Assets/Characters/"+gender+"_Idle_00"+str(skin)+".png"))

func _on_Hair_button_up():
	if hair < 3:
		hair += 1
		$Step2/Body/Hair.set_texture(load("res://Assets/Characters/"+gender+"_IdleHair_00"+str(hair)+".png"))
	else:
		hair = 1
		$Step2/Body/Hair.set_texture(load("res://Assets/Characters/"+gender+"_IdleHair_00"+str(hair)+".png"))

func _on_Eyes_button_up():
	if eyes < 3:
		eyes += 1
		$Step2/Body/Eyes.set_texture(load("res://Assets/Characters/"+gender+"_IdleEyes_00"+str(eyes)+".png"))
	else:
		eyes = 1
		$Step2/Body/Eyes.set_texture(load("res://Assets/Characters/"+gender+"_IdleEyes_00"+str(eyes)+".png"))

func _on_Clothes_button_up():
	if clothes < 3:
		clothes += 1
		$Step2/Body/Clothes.set_texture(load("res://Assets/Characters/"+gender+"_IdleClothes_00"+str(clothes)+".png"))
	else:
		clothes = 1
		$Step2/Body/Clothes.set_texture(load("res://Assets/Characters/"+gender+"_IdleClothes_00"+str(clothes)+".png"))

func _on_Create_button_up():
	character_data.characters.style = {
		'skin': skin,
		'hair': hair,
		'eyes': eyes,
		'clothes': clothes
	}
	global.make_patch_request($Create, 'users/' + global.player_data.user_id, character_data)
