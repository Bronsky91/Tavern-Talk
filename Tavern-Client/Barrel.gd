extends AnimatedSprite

var top
var b_speed
var start = true

func _ready():
	pass
	
func init(_top):
	top = _top
	if top:
		b_speed = 30
		play("Down")
	else:
		b_speed = -30
		play("Up")

func _process(delta):
	if start:
		get_parent().offset = (get_parent().offset + b_speed * delta)
		get_parent().offset = (get_parent().offset + b_speed * delta)

func _on_Barrel_animation_finished():
	if animation == "HillDown" or animation == "HillUp":
		start = true
		if top:
			play("Down")
		else:
			play("Up")

func _on_Area2D_area_entered(area):
	if top and 'bottom' in area.get_parent().name:
		area.get_parent().call_deferred('free')
	elif not top and 'top' in area.get_parent().name:
		area.get_parent().call_deferred('free')
