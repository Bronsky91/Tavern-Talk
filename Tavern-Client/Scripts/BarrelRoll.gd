extends Node2D

export(PackedScene) var barrel_scene

onready var barrel = $Paths/Right/PathFollow2D

var start = false
var b_speed = 100

func _ready():
	$Paths/Right/PathFollow2D/Barrel.play("Down")
	$Paths/Middle/PathFollow2D/Barrel.play("Down")

func _process(delta):
	if start:
		$Paths/Right/PathFollow2D.offset = ($Paths/Right/PathFollow2D.offset + 260 * delta)
		$Paths/Middle/PathFollow2D.offset = ($Paths/Middle/PathFollow2D.offset + 200 * delta)

func _on_Start_button_up():
	start = true

func _on_Area2D_area_entered(area):
	b_speed = 0
	$Paths/Middle/PathFollow2D/Barrel.z_index = 1
	$Paths/Middle/PathFollow2D/Barrel.play("HillDown")
	start = false

func _on_Barrel_animation_finished():
	if $Paths/Middle/PathFollow2D/Barrel.animation == "HillDown":
		$Paths/Middle/PathFollow2D/Barrel.play("Down")
		start = true
		b_speed = 100
