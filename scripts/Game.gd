extends Node2D

func _ready():
	# Instantiate players based on network data
	NetworkManager.connect("player_joined", self, "_on_player_joined")
	
	# Show color selection UI for local player
	$UI/ColorSelection.visible = true

func _on_player_joined(player_id):
	var player_scene = preload("res://scenes/Player.tscn")
	var player = player_scene.instance()
	player.player_id = player_id
	$Players.add_child(player)
