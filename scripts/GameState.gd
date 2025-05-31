extends Node

var players = {}
var game_phase: String = "lobby"
var world_state = {
	"player_positions": {},
	"game_objects": {},
	"scores": {}
}

func update_player_position(player_id: String, position: Vector2):
	if players.has(player_id):
		players[player_id].position = position
		world_state.player_positions[player_id] = position

func get_global_state():
	return world_state.duplicate()

func reset_state():
	players.clear()
	world_state.player_positions.clear()
	world_state.game_objects.clear()
	world_state.scores.clear()
	game_phase = "lobby"
