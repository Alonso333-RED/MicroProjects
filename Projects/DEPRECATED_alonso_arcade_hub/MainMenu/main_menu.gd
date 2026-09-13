extends Control

@export var game_list: GameList

@onready var preview = $GridContainer/preview
@onready var name_label = $GridContainer/ScrollContainer/VBoxContainer/Name
@onready var desc_label = $GridContainer/ScrollContainer/VBoxContainer/Description
@onready var back_btn = $GridContainer/VBoxContainer/HBoxContainer2/back
@onready var play_btn = $GridContainer/VBoxContainer/HBoxContainer2/play
@onready var next_btn = $GridContainer/VBoxContainer/HBoxContainer2/next

var current_index := 0

func _ready():
	update_ui()
	
	back_btn.pressed.connect(_on_Back_pressed)
	play_btn.pressed.connect(_on_Play_pressed)
	next_btn.pressed.connect(_on_Next_pressed)

func update_ui():
	var game = game_list.games[current_index]
	if game.preview != "":
		var texture : Texture2D = load(game.preview)
		preview.texture = texture
	else:
		preview.texture = null

	name_label.text = game.name
	desc_label.text = game.description

func _on_Back_pressed():
	current_index = (current_index - 1 + game_list.games.size()) % game_list.games.size()
	update_ui()

func _on_Next_pressed():
	current_index = (current_index + 1) % game_list.games.size()
	update_ui()

func _on_Play_pressed():
	var game = game_list.games[current_index]
	get_tree().change_scene_to_file(game.scene)
