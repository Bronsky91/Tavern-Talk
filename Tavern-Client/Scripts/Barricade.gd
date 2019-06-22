extends Sprite

var top

func _ready():
	pass # Replace with function body.

func init(l, pos):
	if l.y == 'BarricadeTop':
		top = true
	else:
		top = false
	position = pos

func _on_Area2D_area_entered(area):
	# if barricade is on bottom, and barrel is from top
	# if barricade is on top, and barrel is from bottom
	if not top and area.owner.top:
		#area.owner.break_barrel()
		call_deferred('free')
	elif top and not area.owner.top:
		#area.owner.break_barrel()
		call_deferred('free')