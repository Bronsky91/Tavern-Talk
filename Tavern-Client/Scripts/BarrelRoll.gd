extends Node2D

class_name BarrelRoll

export(PackedScene) var barrel_scene: PackedScene
export(PackedScene) var barricade_scene: PackedScene

var barrel_count: int = 0
var barricade_count: int = 0
var top_heart_count: int = 5
var bottom_heart_count: int = 5
var round_started: bool = false

func _ready():
	$Body/AnimationPlayer.play()
		
func _process(delta):
	if barrel_count == 3:
		$UI/BarrelButton.disabled = true
	if barricade_count == 1:
		$UI/BarricadeButton.disabled = true
	if get_tree().get_nodes_in_group("barrels").size() == 0 and round_started:
		new_round()
		round_started = false
	if $UI/Barrel.visible:
		$UI/Barrel.position = get_global_mouse_position()
	if $UI/Barricade.visible:
		$UI/Barricade.position = get_global_mouse_position()

func drop_barrel() -> void:
	var bottom_b_check: Dictionary = {}
	for start in get_tree().get_nodes_in_group('starts'):
		if 'Bottom' in start.name:
			bottom_b_check[start] = get_global_mouse_position().distance_to(start.get_global_position())
	var spawned_barrel_pos: Position2D = find_closest_path(bottom_b_check)
	spawn_barrel({'y': spawned_barrel_pos.name, 'x': spawned_barrel_pos.get_parent().name})
	barrel_count = barrel_count + 1
	$UI/Barrel.visible = false

func drop_barricade() -> void:
	var bottom_bar_check: Dictionary = {}
	for b_start in get_tree().get_nodes_in_group('barricade_starts'):
		if 'Bottom' in b_start.name:
			bottom_bar_check[b_start] = get_global_mouse_position().distance_to(b_start.get_global_position())
	var spawned_barricade_pos: Position2D = find_closest_path(bottom_bar_check)
	var barricade_location: Dictionary = {'y': spawned_barricade_pos.name, 'x': spawned_barricade_pos.get_parent().name}
	spawn_barricade(barricade_location)
	barricade_count = barricade_count + 1
	$UI/Barricade.visible = false
	
func _input(event: InputEvent):
	if $UI/Barrel.visible:
		if event.get_class() == 'InputEventMouseButton' or event.get_class() == 'InputEventScreenTouch':
			if event.pressed == false:
				drop_barrel()
	if $UI/Barricade.visible:
		if event.get_class() == 'InputEventMouseButton' or event.get_class() == 'InputEventScreenTouch':
			if event.pressed == false:
				drop_barricade()

func find_closest_path(check_dict: Dictionary) -> Position2D:
	var closest_path: Position2D
	var position_array: Array = []
	for b in check_dict:
		position_array.append(check_dict[b])
	position_array.sort()
	var closest: Position2D = position_array[0]
	for b in check_dict:
		if check_dict[b] == closest:
			closest_path = b
	return closest_path
	
func spawn_barrel(location: Dictionary) -> void:
	# location = {y: Top/Bottom, x: Left/Middle/Right}
	var path: Position2D = get_node("Paths/"+location.x)
	var new_barrel: Barrel  = barrel_scene.instance()
	new_barrel.init(location)
	new_barrel.name = location.y.to_lower() + '_barrel' + '_' + str(path.get_child_count())
	if location.x == "Middle":
		if location.y == "Top":
			new_barrel.z_index = 0
		else:
			new_barrel.z_index = 2
	if location.y == 'Bottom':
		var barrel_count = 0
		for node in path.get_children():
			if 'barrel' in node.name and 'bottom' in node.name:
				barrel_count = barrel_count + 1
		new_barrel.offset = new_barrel.offset - (barrel_count * 50)
	else:
		var barrel_count = 0
		for node in path.get_children():
			if 'barrel' in node.name and 'top' in node.name:
				barrel_count = barrel_count + 1
		new_barrel.offset = new_barrel.offset + (barrel_count * 50)
	path.add_child(new_barrel)
	new_barrel.add_to_group('barrels')

func spawn_barricade(location: Dictionary) -> void:
	# location = {y: BarricadeTop/BarricadeBottom, x: Left/Middle/Right}
	var path: Position2D = get_node("Paths/"+location.x)
	var new_barricade = barricade_scene.instance()
	new_barricade.name = location.y.to_lower() + '_barricade' + '_' + str(path.get_child_count())
	new_barricade.init(location, get_node("Paths/"+location.x+"/"+location.y).position)
	path.add_child(new_barricade)
	new_barricade.z_index = 3
	new_barricade.add_to_group('barricades')

func _on_Area2D_area_entered(area: Area2D):
	if area.owner != null:
		if area.owner.top:
			area.owner.z_index = 1
			area.get_parent().play("HillDown")
			area.owner.start = false

func _on_Area2D_area_exited(area: Area2D):
	if area.owner != null:
		if not area.owner.top:
			area.owner.z_index = 0
			area.get_parent().play("HillUp")
			area.owner.start = false

func _on_BarrelButton_button_down():
	$UI/Barrel.visible = true

func _on_BarricadeButton_button_down():
	$UI/Barricade.visible = true

func npc_spawn(y, count) -> void:
	var lanes: Array = ['Left', 'Middle', 'Right']
	for i in range(count):
		randomize()
		if 'Barricade' in y:
			spawn_barricade({'y':y ,'x':lanes[randi()%3]})
		else:
			spawn_barrel({'y':y ,'x':lanes[randi()%3]})

func _on_Start_button_up():
	$UI/Start.disabled = true
	round_started = true
	$UI/BarrelButton.disabled = true
	$UI/BarricadeButton.disabled = true
	npc_spawn('Top', 3)
	npc_spawn('BarricadeTop', 1)
	for b in get_tree().get_nodes_in_group('barrels'):
		b.start = true

func barrel_hit(top: bool) -> void:
	if top and bottom_heart_count > 0:
		get_node("UI/Bottom_Player/Heart_"+str(bottom_heart_count)).set_texture(load("res://Assets/MiniGames/BarrelRoll_Heart_002.png"))
		bottom_heart_count = bottom_heart_count - 1
	elif not top and top_heart_count > 0:
		get_node("UI/Top_Player/Heart_"+str(top_heart_count)).set_texture(load("res://Assets/MiniGames/BarrelRoll_Heart_002.png"))
		top_heart_count = top_heart_count - 1

func new_round() -> void:
	if top_heart_count == 0 and bottom_heart_count == 0:
		$UI/ConfirmationDialog.window_title = "Tie!"
		$UI/ConfirmationDialog.popup()
	elif top_heart_count == 0 and bottom_heart_count != 0:
		$UI/ConfirmationDialog.window_title = "You Win!"
		$UI/ConfirmationDialog.popup()
	elif bottom_heart_count == 0 and top_heart_count != 0:
		$UI/ConfirmationDialog.window_title = "Barmaid Wins!"
		$UI/ConfirmationDialog.popup()
	$UI/Start.disabled = false
	$UI/BarrelButton.disabled = false
	$UI/BarricadeButton.disabled = false
	barrel_count = 0
	barricade_count = 0
	var paths: Array = ["Left", "Right", "Middle"]
	for path in paths:
		for c in get_node("Paths/"+path).get_children():
			if 'barricade' in c.name:
				c.call_deferred("free")

func _on_ConfirmationDialog_confirmed():
	new_game()

func new_game() -> void:
	bottom_heart_count = 5
	top_heart_count = 5
	for h in $UI/Bottom_Player.get_children():
		h.set_texture(load("res://Assets/MiniGames/BarrelRoll_Heart_001.png"))
	for h in $UI/Top_Player.get_children():
		h.set_texture(load("res://Assets/MiniGames/BarrelRoll_Heart_001.png"))

func _on_ConfirmationDialog_popup_hide():
	queue_free()

