extends Button

@onready var root = get_tree().current_scene

var row
var col

func _pressed():
	root.cell_clicked(self)
