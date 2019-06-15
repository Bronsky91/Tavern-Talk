extends Node2D

export(PackedScene) var barrel_scene

func _ready():
	var right_barrel = barrel_scene.instance()
	right_barrel.init(true)
	get_node("Paths/Right/TopFollow").add_child(right_barrel)
	
	var left_barrel = barrel_scene.instance()
	left_barrel.init(true)
	get_node("Paths/Left/TopFollow").add_child(left_barrel)
	
	var middle_barrel = barrel_scene.instance()
	middle_barrel.init(true)
	middle_barrel.name = 'top_barrel'
	middle_barrel.z_index = 0
	get_node("Paths/Middle/TopFollow").add_child(middle_barrel)
	
	var b_middle_barrel = barrel_scene.instance()
	b_middle_barrel.init(false)
	b_middle_barrel.z_index = 0
	b_middle_barrel.name = 'bottom_barrel'
	print(get_node("Paths/Middle/BottomFollow").position)
	get_node("Paths/Middle/BottomFollow").add_child(b_middle_barrel)
	
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
