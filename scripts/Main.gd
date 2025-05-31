extends Node

func _ready():
    NetworkManager.initialize()
    get_tree().change_scene("res://scenes/LoginScene.tscn")