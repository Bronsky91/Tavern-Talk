extends Node2D

onready var p_bar = $ProgressBar

var left_player = {}
var right_player ={}

var end = false
var start = false
var countdown = 3
var spectator

func _ready():
	pass

func _process(delta):
	pass

func spectator():
	$WrestleTap.visible = false
	$WrestleTap.disabled = true
	spectator = true

func initiate(l, r):
	## Called from table, each player's network id and stat mod is passed through
	left_player = l
	$Player1.text = left_player.name
	right_player = r
	$Player2.text = right_player.name

sync func tap(left_player, mod):
	if p_bar.value != 50 or p_bar.value != 0:
		if left_player:
			p_bar.value += mod if mod > 0 else (1 - (-0.2 * mod))
		else:
			p_bar.value -= mod if mod > 0 else (1 - (-0.2 * mod))

func _on_WrestleTap_button_down():
	if left_player.id == get_tree().get_network_unique_id():
		rpc("tap", true, left_player.mod)
	else:
		rpc("tap", false, right_player.mod)
	
sync func declare_winner(winner):
	$WrestleTap.disabled = true
	$WrestleTap.visible = false
	$Winner.text = "THE WINNER IS " + winner.to_upper()
	$Winner.visible = true
	$Close.disabled = false
	$Close.visible = true

func _on_ProgressBar_value_changed(value):
	if value == 50 and not end:
		end = true
		rpc("declare_winner", left_player.name)
	elif value == 0 and not end:
		end = true
		rpc("declare_winner", right_player.name)

func _on_Close_button_up():
	queue_free()

func _on_Countdown_timeout():
	if start:
		$WrestleTap.disabled = false
		$Countdown.stop()
		$CountdownLabel.hide()
	$CountdownLabel.text = "Starting in.. " + str(countdown)
	countdown -= 1
	if countdown == 0:
		start = true
