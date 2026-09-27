extends Control


@onready var ip_line_edit: LineEdit = $rootContainer/leftContainer/playContainer/ipLineEdit
@onready var port_line_edit: LineEdit = $rootContainer/leftContainer/playContainer/portLineEdit

@onready var connect_button: Button = $rootContainer/leftContainer/playContainer/playButtons/connectButton
@onready var disconnect_button: Button = $rootContainer/leftContainer/playContainer/playButtons/disconnectButton
@onready var host_button: Button = $rootContainer/leftContainer/playContainer/playButtons/hostButton


func _ready():
	connect_button.pressed.connect(_on_connect_button_pressed)
	disconnect_button.pressed.connect(_on_disconnect_button_pressed)
	host_button.pressed.connect(_on_host_button_pressed)

	disconnect_button.disabled = true

	# Valores iniciales
	if port_line_edit.text.is_empty():
		port_line_edit.text = "7000"

	if ip_line_edit.text.is_empty():
		ip_line_edit.text = "127.0.0.1"


func _on_host_button_pressed():
	var port := int(port_line_edit.text)

	if port <= 0 or port > 65535:
		print("Puerto inválido")
		return

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port)

	if error != OK:
		print("No se pudo crear el servidor: ", error)
		return

	multiplayer.multiplayer_peer = peer

	print("Servidor creado en el puerto ", port)

	get_tree().change_scene_to_file("res://Game.tscn")


func _on_connect_button_pressed():
	var ip := ip_line_edit.text.strip_edges()
	var port := int(port_line_edit.text)

	if ip.is_empty():
		print("Debes introducir una IP")
		return

	if port <= 0 or port > 65535:
		print("Puerto inválido")
		return

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(ip, port)

	if error != OK:
		print("No se pudo iniciar la conexión: ", error)
		return

	multiplayer.multiplayer_peer = peer

	print("Conectando a ", ip, ":", port)

	# Esperamos a que realmente se conecte
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _on_connected_to_server():
	print("Conectado al servidor")

	get_tree().change_scene_to_file("res://Game.tscn")


func _on_disconnect_button_pressed():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()

	multiplayer.multiplayer_peer = null

	print("Desconectado")
