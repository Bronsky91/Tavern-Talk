extends Node2D

export(PackedScene) var barrel_scene

var barrel_count = 0

func _ready():
	$Paths/Left/Bottom.add_to_group('starts')
	$Paths/Middle/Bottom.add_to_group('starts')
	$Paths/Right/Bottom.add_to_group('starts')
	$Paths/Left/Top.add_to_group('starts')
	$Paths/Middle/Top.add_to_group('starts')
	$Paths/Right/Top.add_to_group('starts')
	
func _input(event):
	if barrel_count == 3:
		$UI/Barrel.visible = false
	if $UI/Barrel.visible and (event is InputEventScreenTouch or event.is_action_pressed('click')):
		var top_b_check = {}
		var bottom_b_check = {}
		for start in get_tree().get_nodes_in_group('starts'):
			if 'Bottom' in start.name:
				bottom_b_check[start] = get_global_mouse_position().distance_to(start.get_global_position())
		var spawned_barrel = find_closest_path(bottom_b_check)
		spawn_barrel({'y': spawned_barrel.name, 'x': spawned_barrel.get_parent().name})
		barrel_count = barrel_count + 1
	
func find_closest_path(check_dict):
	print(check_dict)
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
	
func spawn_barrel(location):
	# location = {y: Top/Bottom, x: Left/Middle/Right}
	var path = get_node("Paths/"+location.x)
	var new_barrel = barrel_scene.instance()
	new_barrel.init(location)
	new_barrel.name = location.y.to_lower() + '_barrel' + '_' + str(path.get_child_count())
	if location.x == "Middle":
		new_barrel.z_index = 0
	if location.y == 'Bottom':
		new_barrel.offset = new_barrel.offset - ((path.get_child_count() - 2) * 75)
		path.add_child(new_barrel)
	new_barrel.add_to_group('barrels')

func _on_Area2D_area_entered(area):
	if 'top' in area.get_parent().name:
		area.get_parent().z_index = 1
		area.get_parent().play("HillDown")
		area.get_parent().start = false

func _on_Area2D_area_exited(area):
	if 'bottom' in area.get_parent().name:
		area.get_parent().z_index = 0
		area.get_parent().play("HillUp")
		area.get_parent().start = false

func _on_BarrelButton_button_up():
	$UI/Barrel.visible = true

func _on_Start_button_up():
	for b in get_tree().get_nodes_in_group('barrels'):
		b.start = true
