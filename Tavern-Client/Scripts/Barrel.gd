extends PathFollow2D

var MIDDLE_MAX_OFFSET = 393
var RIGHT_MAX_OFFSET = 549.15
var LEFT_MAX_OFFSET = 536.11

var top
var b_speed
var start = false
var broke = false

func _ready():
	pass
	
func init(l):
	if l.y == 'Top':
		top = true
		b_speed = 50
		get_child(0).play("Down")
	else:
		if l.x == 'Middle':
			offset = MIDDLE_MAX_OFFSET
		elif l.x == 'Right':
			offset = RIGHT_MAX_OFFSET
		elif l.x == 'Left':
			offset = LEFT_MAX_OFFSET
		top = false
		b_speed = -50
		get_child(0).play("Up")

func _process(delta):
	if start:
		offset = (offset + b_speed * delta)
		offset = (offset + b_speed * delta)
		if top:
			if offset > RIGHT_MAX_OFFSET and not broke:
				broke = true
				get_parent().owner.barrel_hit(true)
				break_barrel()
		else:
			if offset < 0 and not broke:
				broke = true
				get_parent().owner.barrel_hit(false)
				break_barrel()

func _on_Barrel_animation_finished():
	if get_child(0).animation == "Break" or b_speed == 0:
		call_deferred("free")
	if get_child(0).animation == "HillDown" or get_child(0).animation == "HillUp":
		start = true
		if top:
			get_child(0).play("Down")
		else:
			get_child(0).play("Up")

func _on_Area2D_area_entered(area):
	if top and 'bottom' in area.owner.name:
		break_barrel()
	elif not top and 'top' in area.owner.name:
		break_barrel()

func break_barrel():
	get_parent().owner.barrel_bye_bye()
	$Barrel/Area2D.set_deferred("monitorable", false)
	get_child(0).play("Break")
	print(name)
	b_speed = 0
	