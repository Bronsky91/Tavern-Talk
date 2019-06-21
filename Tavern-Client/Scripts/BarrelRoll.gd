extends Node2D

export(PackedScene) var barrel_scene
export(PackedScene) var barricade_scene

var barrel_count = 0
var barricade_count = 0
var top_heart_count = 5
var bottom_heart_count = 5
var total_barrel_count = 0

func _ready():
	$Paths/Left/Bottom.add_to_group('starts')
	$Paths/Middle/Bottom.add_to_group('starts')
	$Paths/Right/Bottom.add_to_group('starts')
	$Paths/Left/Top.add_to_group('starts')
	$Paths/Middle/Top.add_to_group('starts')
	$Paths/Right/Top.add_to_group('starts')
	
	$Paths/Left/BarricadeBottom.add_to_group('barricade_starts')
	$Paths/Right/BarricadeBottom.add_to_group('barricade_starts')
	$Paths/Middle/BarricadeBottom.add_to_group('barricade_starts')
	$Paths/Left/BarricadeTop.add_to_group('barricade_starts')
	$Paths/Right/BarricadeTop.add_to_group('barricade_starts')
	$Paths/Middle/BarricadeTop.add_to_group('barricade_starts')
	
func _input(event):
	if barrel_count == 3:
		$UI/Barrel.visible = false
	if barricade_count == 1:
		$UI/Barricade.visible = false
	if $UI/Barrel.visible and (event is InputEventScreenTouch or event.is_action_pressed('click')):
		#var top_b_check = {}
		var bottom_b_check = {}
		for start in get_tree().get_nodes_in_group('starts'):
			if 'Bottom' in start.name:
				bottom_b_check[start] = get_global_mouse_position().distance_to(start.get_global_position())
		var spawned_barrel = find_closest_path(bottom_b_check)
		spawn_barrel({'y': spawned_barrel.name, 'x': spawned_barrel.get_parent().name})
		barrel_count = barrel_count + 1
	if $UI/Barricade.visible and (event is InputEventScreenTouch or event.is_action_pressed('click')):
		var bottom_bar_check = {}
		for b_start in get_tree().get_nodes_in_group('barricade_starts'):
			if 'Bottom' in b_start.name:
				bottom_bar_check[b_start] = get_global_mouse_position().distance_to(b_start.get_global_position())
		var spawned_barricade = find_closest_path(bottom_bar_check)
		var barricade_location = {'y': spawned_barricade.name, 'x': spawned_barricade.get_parent().name}
		spawn_barricade(barricade_location)
		barricade_count = barricade_count + 1

func find_closest_path(check_dict):
	var position_array = []
	for b in check_dict:
		position_array.append(check_dict[b])
	position_array.sort()
	var closest = position_array[0]
	for b in check_dict:
		if check_dict[b] == closest:
			return b
	
func _process(delta):
	if $UI/Barrel.visible:
		$UI/Barrel.position = get_global_mouse_position()
	if $UI/Barricade.visible:
		$UI/Barricade.position = get_global_mouse_position()
	
func spawn_barrel(location):
	# location = {y: Top/Bottom, x: Left/Middle/Right}
	var path = get_node("Paths/"+location.x)
	var new_barrel = barrel_scene.instance()
	new_barrel.init(location)
	new_barrel.name = location.y.to_lower() + '_barrel' + '_' + str(path.get_child_count())
	if location.x == "Middle":
		if location.y == "Top":
			new_barrel.z_index = 0
		else:
			new_barrel.z_index = 2
	if location.y == 'Bottom':
		new_barrel.offset = new_barrel.offset - ((path.get_child_count() - 5) * 50)
	else:
		new_barrel.offset = new_barrel.offset + ((path.get_child_count() - 5) * 50)
	path.add_child(new_barrel)
	new_barrel.add_to_group('barrels')
	
func spawn_barricade(location):
	# location = {y: BarricadeTop/BarricadeBottom, x: Left/Middle/Right}
	var path = get_node("Paths/"+location.x)
	var new_barricade = barricade_scene.instance()
	new_barricade.name = location.y.to_lower() + '_barricade' + '_' + str(path.get_child_count())
	new_barricade.init(location, get_node("Paths/"+location.x+"/"+location.y).position)
	path.add_child(new_barricade)
	new_barricade.add_to_group('barricades')

func _on_Area2D_area_entered(area):
	if area.owner.top:
		area.owner.z_index = 1
		area.get_parent().play("HillDown")
		area.owner.start = false

func _on_Area2D_area_exited(area):
	if area.owner != null:
		if not area.owner.top:
			area.owner.z_index = 0
			area.get_parent().play("HillUp")
			area.owner.start = false

func _on_BarrelButton_button_up():
	$UI/Barrel.visible = true

func _on_BarricadeButton_button_up():
	$UI/Barricade.visible = true
	
func npc_spawn(y, count):
	var lanes = ['Left', 'Middle', 'Right']
	for i in range(count):
		randomize()
		if 'Barricade' in y:
			spawn_barricade({'y':y ,'x':lanes[randi()%3]})
		else:
			spawn_barrel({'y':y ,'x':lanes[randi()%3]})

func _on_Start_button_up():
	npc_spawn('Top', 3)
	npc_spawn('BarricadeTop', 1)
	for b in get_tree().get_nodes_in_group('barrels'):
		b.start = true
		
func barrel_hit(top):
	if top:
		get_node("UI/Bottom_Player/Heart_"+str(bottom_heart_count)).set_texture(load("res://Assets/MiniGames/BarrelRoll_Heart_002.png"))
		bottom_heart_count = bottom_heart_count - 1
		if bottom_heart_count == 0:
			print('Top is winner!')
	else:
		get_node("UI/Top_Player/Heart_"+str(top_heart_count)).set_texture(load("res://Assets/MiniGames/BarrelRoll_Heart_002.png"))
		top_heart_count = top_heart_count - 1
		if top_heart_count == 0:
			print('Bottom is winner!')
	
func barrel_bye_bye():
	total_barrel_count = total_barrel_count + 1
	if total_barrel_count == 6:
		## Round over ##
		barrel_count = 0
		barricade_count = 0
		total_barrel_count = 0
		var paths = ["Left", "Right", "Middle"]
		for path in paths:
			for c in get_node("Paths/"+path).get_children():
				if 'barricade' in c.name:
					c.call_deferred("free") 
	return total_barrel_count