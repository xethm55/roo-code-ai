extends Node

# HathoraSDK is an autoload singleton (see addons/hathora/sdk/hathora_sdk.gd)
# No need to preload or create an instance

var current_room_id: String = ""
var player_sessions = {}
var auth_token: String = ""
var player_color: Color = Color.WHITE
var player_nickname: String = "Player"

signal authentication_result(success)
signal connection_established()

func authenticate(nickname: String):
	player_nickname = nickname
	
	# For local development, skip remote authentication
	if OS.has_environment("HATHORA_LOCAL"):
		auth_token = "local_token" 
		print("Local authentication for: ", player_nickname)
		emit_signal("authentication_result", true)
		# Join a hardcoded local room
		join_room("local-room", player_color)
	else:
		# Remote authentication
		var res = await HathoraSDK.auth_v1.login_nickname(player_nickname).async()
		
		if res.is_error():
			print("Authentication failed: ", res.as_error().message)
			emit_signal("authentication_result", false)
			return
			
		auth_token = res.get_data().token
		print("Authenticated as: ", player_nickname)
		emit_signal("authentication_result", true)
		
		# After authentication, get lobby info and join room
		var lobby_res = await HathoraSDK.lobby_v3.get_info_by_short_code(
			auth_token,
			"default"  # Use your lobby short code here
		).async()
		
		if lobby_res.is_error():
			print("Lobby info error: ", lobby_res.as_error().message)
			return
			
		join_room(lobby_res.get_data().roomId, player_color)

func create_room(game_type: String, color: Color):
	player_color = color
	var res = await HathoraSDK.lobby_v3.create(
		auth_token,
		HathoraSDK.Visibility.PUBLIC,
		HathoraSDK.Region.FRANKFURT
	).async()
	
	if res.is_error():
		print("Room creation failed: ", res.as_error().message)
		return
		
	current_room_id = res.get_data().roomId
	print("Created lobby with roomId: ", current_room_id)
	join_room(current_room_id, color)

func join_room(room_id: String, color: Color):
	player_color = color
	current_room_id = room_id
	await join_room_id(room_id)

func join_room_id(room_id: String):
	var res = await HathoraSDK.room_v2.get_connection_info(room_id).async()
	if res.is_error():
		print("Connection info error: ", res.as_error().message)
		return
		
	var connection_info = res.get_data()
	
	# Retry if room not active
	if connection_info.status != HathoraSDK.RoomStatus.ACTIVE:
		print("Room not active, retrying...")
		await get_tree().create_timer(1.0).timeout
		join_room_id(room_id)
		return
		
	# Create multiplayer client
	var peer = ENetMultiplayerPeer.new()
	var host = connection_info.exposedPort.host
	var port = connection_info.exposedPort.port
	
	# For local development, connect directly to localhost
	if OS.has_environment("HATHORA_LOCAL"):
		host = "localhost"
		print("Using local Hathora server")
	
	var err = peer.create_client(host, port)
	
	if err:
		print("Connection failed: ", err)
		return
		
	multiplayer.multiplayer_peer = peer
	await multiplayer.connected_to_server
	print("Connected to Hathora server at %s:%d!" % [host, port])
	emit_signal("connection_established")
	get_tree().change_scene("res://scenes/GameScene.tscn")

func send_game_state_update(update: Dictionary):
	# Implement actual state syncing
	pass

func _on_player_joined(player_id: String):
	player_sessions[player_id] = {
		"id": player_id,
		"position": Vector2.ZERO,
		"status": "active",
		"color": player_color
	}
