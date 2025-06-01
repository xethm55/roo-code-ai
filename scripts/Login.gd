extends Control

# Loading indicator to show during authentication
@onready var loading_indicator = $VBoxContainer/LoadingIndicator
@onready var error_label = $VBoxContainer/ErrorLabel

func _ready():
	# Hide loading indicator and error label initially
	loading_indicator.hide()
	error_label.hide()

func _on_LoginButton_pressed():
	var nickname = $VBoxContainer/Email.text
	# Show loading indicator and clear previous errors
	loading_indicator.show()
	error_label.hide()
	
	# Authenticate with Hathora
	NetworkManager.authenticate(nickname)
	
	# Connect to authentication result signal
	if not NetworkManager.authentication_result.is_connected(_on_authentication_result):
		NetworkManager.authentication_result.connect(_on_authentication_result)

func _on_authentication_result(success):
	loading_indicator.hide()
	if success:
		# Transition to lobby scene after successful login
		get_tree().change_scene_to_file("res://scenes/LobbyScene.tscn")
	else:
		# Show error message
		error_label.text = "Login failed. Please try again."
		error_label.show()
