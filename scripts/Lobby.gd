extends Control

@onready var room_list = $VBoxContainer/RoomList
@onready var game_type_option = $VBoxContainer/GameTypeOption
@onready var color_picker = $VBoxContainer/ColorPickerButton

func _ready():
	NetworkManager.hathora_client.connect("rooms_updated", self, "_update_room_list")
	
	# Setup game type options
	game_type_option.add_item("Deathmatch")
	game_type_option.add_item("CaptureTheFlag")
	game_type_option.add_item("TeamElimination")

func _on_CreateRoom_pressed():
	var game_type = game_type_option.get_item_text(game_type_option.selected)
	var color = color_picker.color
	NetworkManager.create_room(game_type, color)

func _on_Refresh_pressed():
	NetworkManager.hathora_client.list_rooms_async()

func _update_room_list(rooms: Array):
	room_list.clear()
	for room in rooms:
		room_list.add_item("Room %s (%d/4 players) - %s" % [room.room_id, room.player_count, room.game_type])
