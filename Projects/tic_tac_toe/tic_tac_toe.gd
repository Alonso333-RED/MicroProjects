extends Control

var current
var available = 9
var board = [
	["", "", ""],
	["", "", ""],
	["", "", ""]
]

var x_score = 0
var o_score = 0
@onready var x_counter = $GridContainer/BlueContainer/score;
@onready var o_counter = $GridContainer/RedContainer/score;

@onready var cells = $GridContainer/Center.get_children()

func _ready():
	var index = 0

	for r in range(3):
		for c in range(3):
			cells[index].row = r
			cells[index].col = c
			index += 1

	current = ["X", "O"].pick_random()
	update_turn_visual()

func cell_clicked(cell: Button):
	if cell.text != "":
		return

	cell.text = current

	if current == "X":
		cell.add_theme_color_override("font_color", Color.BLUE)
	else:
		cell.add_theme_color_override("font_color", Color.RED)

	board[cell.row][cell.col] = current

	if check_win(current):
		add_score(current)
		new_match(current)
		return

	available -= 1

	if available <= 0:
		new_match(current)
		return

	current = "O" if current == "X" else "X"
	update_turn_visual()

func update_turn_visual():
	if current == "X":
		$blue.color = Color(0, 0, 0.25)
		$red.color = Color(0, 0, 0)
	else:
		$blue.color = Color(0, 0, 0)
		$red.color = Color(0.25, 0, 0)

func check_win(p):
	for r in range(3):
		if board[r][0] == p and board[r][1] == p and board[r][2] == p:
			return true

	for c in range(3):
		if board[0][c] == p and board[1][c] == p and board[2][c] == p:
			return true

	if board[0][0] == p and board[1][1] == p and board[2][2] == p:
		return true

	if board[0][2] == p and board[1][1] == p and board[2][0] == p:
		return true

	return false
	
func add_score(player):
	if player == "X":
		x_score += 1
		x_counter.text = str(x_score)
	else:
		o_score += 1
		o_counter.text = str(o_score)
		
func new_match(last_winner):
	board = [
		["", "", ""],
		["", "", ""],
		["", "", ""]
	]

	available = 9

	for cell in cells:
		cell.text = ""
		cell.disabled = false

	current = "O" if last_winner == "X" else "X"
	update_turn_visual()
