extends Node2D


const PLAYER_SCENE = preload("res://Player.tscn")


@onready var players: Node2D = $Players


func _ready():
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

		# Crear jugador del servidor
		_spawn_player(multiplayer.get_unique_id())


func _on_peer_connected(peer_id: int):
	print("Jugador conectado: ", peer_id)

	_spawn_player(peer_id)


func _on_peer_disconnected(peer_id: int):
	print("Jugador desconectado: ", peer_id)

	var player = players.get_node_or_null(str(peer_id))

	if player:
		player.queue_free()


func _spawn_player(peer_id: int):
	var player = PLAYER_SCENE.instantiate()

	# El nombre contiene el ID del jugador
	player.name = str(peer_id)

	# IMPORTANTE:
	# NO ponemos set_multiplayer_authority() aquí.

	players.add_child(player)

	print("Jugador creado: ", peer_id)
