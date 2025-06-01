extends CharacterBody2D

var player_id: String
var username: String
var move_speed: float = 200.0

func _physics_process(delta):
	if is_multiplayer_authority():
		var input_vector = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		).normalized()
		
		velocity = input_vector * move_speed
		move_and_slide()
		NetworkManager.send_game_state_update({
			"player_id": player_id,
			"position": position
		})
