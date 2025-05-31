extends Node

var _hathora_client = preload("res://addons/hathora_godot_plugin/hathora_client.gd").new()
var current_room_id: String = ""
var player_sessions = {}
var auth_token: String = ""
var player_color: Color = Color.white

signal authentication_result(success)

func _ready():
    _hathora_client.connect("connection_established", self, "_on_connection_established")
    _hathora_client.connect("room_created", self, "_on_room_created")
    _hathora_client.connect("player_joined", self, "_on_player_joined")

func authenticate(email: String, password: String):
    # Placeholder for Hathora authentication
    auth_token = "dummy_token"
    emit_signal("authentication_result", true)

func create_room(game_type: String, color: Color):
    player_color = color
    _hathora_client.create_room_async(game_type, color)

func join_room(room_id: String, color: Color):
    player_color = color
    _hathora_client.join_room_async(room_id, color)

func send_game_state_update(update: Dictionary):
    _hathora_client.send_room_state(current_room_id, update)

func _on_connection_established():
    print("Connected to Hathora server")

func _on_room_created(room_id: String):
    current_room_id = room_id
    get_tree().change_scene("res://scenes/GameScene.tscn")

func _on_player_joined(player_id: String):
    player_sessions[player_id] = {
        "id": player_id,
        "position": Vector2.ZERO,
        "status": "active",
        "color": player_color
    }