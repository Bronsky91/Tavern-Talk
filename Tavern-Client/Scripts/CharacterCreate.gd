extends Control

onready var menu: MainMenu = get_parent()
onready var character_name: LineEdit = $Step1/NameLabel/Name
onready var gender_list: ItemList = $Step1/GenderLabel/Gender
onready var race_list: ItemList = $Step1/Race/Races
onready var stat_tree: Tree = $Step1/Stats/Tree
onready var animate: AnimationPlayer = $Step2/Body/AnimationPlayer

# Stats tree vars
var strength: TreeItem
var dex: TreeItem
var con: TreeItem
var wis: TreeItem
var cha: TreeItem

var race: String
var gender: String
var skin: int = 1
var hair: int = 1
var eyes: int = 1
var top_clothes: int = 1
var bottom_clothes: int = 1

var c_id: String
var character_data: Dictionary
var edit_mode: bool

func _ready():
	get_tree().set_auto_accept_quit(false)
		
	gender_list.add_item("Male")
	gender_list.add_item("Female")
	
	race_list.add_item("Human")
	race_list.add_item("Elf")
	
	var root: TreeItem = stat_tree.create_item()
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

func _on_Races_item_selected(index):
	race = race_list.get_item_text(index)

func _on_Step2_visibility_changed():
	if $Step2.visible == true:
		$Step2/Body.material.set_shader_param("palette_swap", load('res://Assets/Palettes/Skintones/Skin_{skin}.png'.format({'skin': "%03d" % skin})))
		
		$Step2/Body.set_texture(load("res://Assets/Characters/{race}/{gender}/{gender}_Idle_001.png".format({'race': race, 'gender': gender})))
		$Step2/Body/Hair.set_texture(load("res://Assets/Characters/{race}/{gender}_IdleHair_{hair}.png".format({'race': race, 'gender': gender, 'hair': "%03d" % hair})))
		$Step2/Body/Eyes.set_texture(load("res://Assets/Characters/{race}/{gender}_IdleEyes_{eyes}.png".format({'race': race, 'gender': gender, 'eyes': "%03d" % eyes})))
		$Step2/Body/TopClothes.set_texture(load("res://Assets/Characters/{race}/{gender}_IdleClothes_{top_clothes}.png".format({'race': race, 'gender': gender, 'top_clothes': "%03d" % top_clothes})))
		$Step2/Body/BottomClothes.set_texture(load("res://Assets/Characters/{race}/{gender}_IdleClothes_{bottom_clothes}.png".format({'race': race, 'gender': gender, 'bottom_clothes': "%03d" % bottom_clothes})))
		animate.current_animation = "idle_down_menu"

func _on_Skin_button_up():
	if skin < g.count_files_in_dir("res://Assets/Palettes/Skintones/"):
		skin += 1
		$Step2/Body.material.set_shader_param("palette_swap", load('res://Assets/Palettes/Skintones/Skin_{skin}.png'.format({'skin': "%03d" % skin})))
	else:
		skin = 1
		$Step2/Body.material.set_shader_param("palette_swap", load('res://Assets/Palettes/Skintones/Skin_{skin}.png'.format({'skin': "%03d" % skin})))

func _on_Hair_button_up():
	if hair < g.count_files_in_dir("res://Assets/Palettes/Characters/{race}/{gender}/Hair/".format({'gender': gender, 'race': race})):
		hair += 1
	else:
		hair = 1
	$Step2/Body/Hair.set_texture(load("res://Assets/Characters/{race}/{gender}/Hair/{gender}_IdleHair_{hair}.png".format({'gender': gender, 'race': race, 'hair': "%03d" % hair})))

func _on_Eyes_button_up():
	if eyes < 3:
		eyes += 1
		$Step2/Body/Eyes.set_texture(load("res://Assets/Characters/"+gender+"_IdleEyes_00"+str(eyes)+".png"))
	else:
		eyes = 1
		$Step2/Body/Eyes.set_texture(load("res://Assets/Characters/"+gender+"_IdleEyes_00"+str(eyes)+".png"))

func _on_Clothes_button_up():
	if top_clothes < 3:
		top_clothes += 1
		$Step2/Body/TopClothes.set_texture(load("res://Assets/Characters/"+gender+"_IdleClothes_00"+str(top_clothes)+".png"))
	else:
		top_clothes = 1
		$Step2/Body/TopClothes.set_texture(load("res://Assets/Characters/"+gender+"_IdleClothes_00"+str(top_clothes)+".png"))

func _on_Create_button_up():
	character_data.characters.style = {
		'skin': skin,
		'hair': hair,
		'eyes': eyes,
		'top_clothes': top_clothes
	}
	if edit_mode:
		var data: Dictionary = {"_id": c_id}
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
			top_clothes = character_data.style.top_clothes
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
			top_clothes = 1

