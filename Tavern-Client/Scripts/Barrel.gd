extends PathFollow2D

class_name Barrel

var MIDDLE_MAX_OFFSET: float = 393
var RIGHT_MAX_OFFSET: float = 549.15
var LEFT_MAX_OFFSET: float = 536.11

var top: bool
var b_speed: int
var start: bool = false
var broke: bool = false

func _ready():
	pass
	
func init(l: Dictionary) -> void:
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

func _on_Barrel_animation_finished() -> void:
	if get_child(0).animation == "Break" or b_speed == 0:
		call_deferred("free")
	if get_child(0).animation == "HillDown" or get_child(0).animation == "HillUp":
		start = true
		if top:
			get_child(0).play("Down")
		else:
			get_child(0).play("Up")

func _on_Area2D_area_entered(area: Area2D):
	if top and 'bottom' in area.owner.name:
		break_barrel()
	elif not top and 'top' in area.owner.name:
		break_barrel()

func break_barrel() -> void:
	$Barrel/Area2D.set_deferred("monitorable", false)
	$Barrel/Area2D/CollisionShape2D.set_deferred("disabled", false)
	get_child(0).play("Break")
	b_speed = 0