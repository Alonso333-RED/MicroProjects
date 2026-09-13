extends Button

@export var ghost_mode := false

var holding := false
var hold_time := 0.0
var required_time := 1.0
var activated := false

func _ready():
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

	if ghost_mode:
		_make_hidden()

func _process(delta):
	if holding and not activated:
		hold_time += delta

		if hold_time >= required_time:
			activated = true
			activate()

func _on_button_down():
	holding = true
	hold_time = 0.0
	activated = false

	if ghost_mode:
		_make_visible()

func _on_button_up():
	holding = false
	hold_time = 0.0
	activated = false

	if ghost_mode:
		_make_hidden()

func activate():
	get_tree().reload_current_scene()

func _make_hidden():
	modulate.a = 0.0

func _make_visible():
	modulate.a = 1.0
