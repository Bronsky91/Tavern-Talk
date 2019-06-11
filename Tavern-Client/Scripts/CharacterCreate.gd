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

var c_id
var character_data = {}
var edit_mode

func _ready():
	get_tree().set_auto_accept_quit(false)
		
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
	
		
func _process(delta):
	if g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = g.distance_to_raise(get_focus_owner())
	elif OS.get_virtual_keyboard_height() == 0 and not g.is_lower_than_keyboard(get_focus_owner()):
		get_parent().position.y = 0
	
func _on_Create_request_completed(result, response_code, headers, body):
	if response_code == 200:
		menu.change_menu_scene(self, menu.get_node('CharacterSelect'))
		$Step1.visible = true
		$Step2.visible = false
	if edit_mode and response_code == 404:
		g.make_patch_request($Create, 'users/' + g.player_data.user_id, character_data)

func _on_CreateButton_button_up():
	if gender and character_name.text != "":
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
	if $Step2.visible == true:
		$Step2.hide()
		$Step1.show()
	else:
		character_data = {}
		menu.change_menu_scene(self, menu.get_node('CharacterSelect'))

func _on_Gender_item_selected(index):
	gender = gender_list.get_item_text(index)

func _on_Step2_visibility_changed():
	if $Step2.visible == true:
		$Step2/Body.set_texture(load("res://Assets/Characters/"+gender+"_Idle_00"+str(skin)+".png"))
		$Step2/Body/Hair.set_texture(load("res://Assets/Characters/"+gender+"_IdleHair_00"+str(hair)+".png"))
		$Step2/Body/Eyes.set_texture(load("res://Assets/Characters/"+gender+"_IdleEyes_00"+str(eyes)+".png"))
		$Step2/Body/Clothes.set_texture(load("res://Assets/Characters/"+gender+"_IdleClothes_00"+str(clothes)+".png"))
		animate.current_animation = "idle_down_menu"

func _on_Skin_button_up():
	if skin < 3:
		skin += 1
		$Step2/Body.set_texture(load("res://Assets/Characters/"+gender+"_Idle_00"+str(skin)+".png"))
	else:
		skin = 1
		$Step2/Body.set_texture(load("res://Assets/Characters/"+gender+"_Idle_00"+str(skin)+".png"))

func _on_Hair_button_up():
	if hair < 4:
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
	if edit_mode:
		var data = {"_id": c_id}
		g.make_patch_request($Create, 'users/' + g.player_data.user_id + '/character_remove', data)
	else:
		g.make_patch_request($Create, 'users/' + g.player_data.user_id, character_data)

func _on_CharacterCreate_visibility_changed():
	if visible == true:
		if edit_mode:
			$Title.text = "Edit Character"
			$Step2/Create.text = "Save"
			$Step1/NameLabel/Name.text = character_data.name
			$Step1/GenderLabel/Gender.select(0 if character_data.gender == "Male" else 1)
			gender = character_data.gender
			strength.set_range(1, character_data.stats.strength)
			dex.set_range(1, character_data.stats.dex)
			con.set_range(1, character_data.stats.con)
			wis.set_range(1, character_data.stats.wis)
			cha.set_range(1, character_data.stats.cha)
			skin = character_data.style.skin
			hair = character_data.style.hair
			eyes = character_data.style.eyes
			clothes = character_data.style.clothes
		else:
			$Title.text = "Create Character"
			$Step2/Create.text = "Create"
			$Step1/NameLabel/Name.text = ""
			$Step1/GenderLabel/Gender.unselect_all()
			gender = ""
			strength.set_range(1, 10)
			dex.set_range(1, 10)
			con.set_range(1, 10)
			wis.set_range(1, 10)
			cha.set_range(1, 10)
			skin = 1
			hair = 1
			eyes = 1
			clothes = 1
			