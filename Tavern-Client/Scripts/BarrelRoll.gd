extends Node2D

export(PackedScene) var barrel_scene

onready var barrel = $Paths/Right/PathFollow2D

var start = false

func _ready():
	$Paths/Right/PathFollow2D/Barrel.playing = true
	$Paths/Middle/PathFollow2D/Barrel.playing = true

func _process(delta):
	if start:
		$Paths/Right/PathFollow2D.offset = ($Paths/Right/PathFollow2D.offset + 260 * delta)
		$Paths/Middle/PathFollow2D.offset = ($Paths/Middle/PathFollow2D.offset + 200 * delta)

func _on_Start_button_up():
	start = true
