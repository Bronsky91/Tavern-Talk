extends Node2D

onready var p_bar = $ProgressBar

var left_player = {}
var right_player ={}

var end = false

func _ready():
	pass

func _process(delta):
	pass

func initiate(l, r):
	## Called from table, each player's network id and stat mod is passed through
	left_player = l
	right_player = r

sync func tap(left_player, mod):
	if p_bar.value != 100 or p_bar.value != 0:
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
	if winner.id == get_tree().get_network_unique_id():
		print('you win!')
	else:
		print('you lose :(')
	queue_free()

func _on_ProgressBar_changed():
	if p_bar.value == 100 and not end:
		end = true
		rpc("declare_winner", left_player)
	elif p_bar.value == 0 and not end:
		end = true
		rpc("declare_winner", right_player)
