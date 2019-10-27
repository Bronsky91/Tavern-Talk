extends Node

var menu_start = false

func _ready():
	pass # Replace with function body.

func turn_on(music):
	print(Tree)
	if music == 'menu':
		menu_start = true
		$MenuMusic.play()
	if music == 'song':
		menu_start = false
		$TavernSong1.play()
		$SoftAmbience.play()

func turn_off(music):
	if music == 'menu':
		$MenuMusic.stop()
	if music == 'song':
		$TavernSong1.stop()
		$SoftAmbience.stop()

func _on_TavernSong1_finished():
	turn_on('menu')

func _on_MenuMusic_finished():
	if menu_start:
		turn_on('menu')
	else:
		turn_on('song')
