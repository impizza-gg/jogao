extends Node

signal player_added(id: int, playerName: String, admin: bool)
signal player_disconnected_signal(id: int)

@onready var MainMenu := %MainMenu
@onready var WaitingRoom := %WaitingRoom

var peer := ENetMultiplayerPeer.new()
var connected_players := {}

signal new_room()

func _ready() -> void:
	multiplayer.allow_object_decoding = true
	Signals.change_player_character.connect(change_player_character)


func _on_main_menu_create_room(playerName: String) -> void:	
	var ip : String
	
	if OS.has_feature("windows"):
		ip = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4)
	else:
		ip = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), IP.TYPE_IPV4)
	var port := 135
		
	var HOST_ERROR = peer.create_server(int(port))
	
	if HOST_ERROR != OK:
		print("NETWORK: HOST ERROR")
		return
		
	multiplayer.multiplayer_peer = peer
	connected_players.clear()
	if not multiplayer.is_connected("peer_disconnected", player_disconnected):
		multiplayer.peer_disconnected.connect(player_disconnected)
	add_player(peer.get_unique_id(), playerName, true)
	MainMenu.hide()
	
	WaitingRoom.ip = ip + ":" + str(port)
	WaitingRoom.StartButton.visible = true
	WaitingRoom.show()
	new_room.emit()

# botando isso aqui porque eu esqueci como funcionava algumas vezes
# essa função é chamada pelos clients quando se conectam no server
# usando rpc_id(1, ...)
@rpc("any_peer", "call_remote")
func add_player(id: int, player_name: String, admin := false):
	print("Adding player: " + player_name + " id: " + str(id))
	
	player_added.emit(id, player_name, admin)
	connected_players[id] = {
		"player_name": player_name,
		"points": 0,
		"character": 0,
		"alive": true
	}
	
	
func _on_main_menu_join_room(playerName: String, ipPort: String) -> void:
	var ip := ipPort.split(":")[0]
	var port := int(ipPort.split(":")[1])
	
	var JOIN_ERROR := peer.create_client(ip, port)
	if JOIN_ERROR != OK:
		print("NETWORK: JOIN ERROR")
		return
		
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(connected_to_server.bind(playerName))
	multiplayer.server_disconnected.connect(back)
	
	MainMenu.hide()
	WaitingRoom.ip = ipPort

	WaitingRoom.StartButton.visible = false
	WaitingRoom.show()


func connected_to_server(playerName: String):
	var error = rpc_id(1, "add_player", peer.get_unique_id(), playerName)
	if error: 
		print("error: " + str(error))


func _on_waiting_room_leave_room() -> void:
	back()


func back() -> void:
	# TODO: alert popup: Connection closed by host
	WaitingRoom.clear_player_list()
	
	# tá dando um "erro" porque o cliente tenta fechar a conexão que o servidor já fechou
	# mas funciona igual
	#multiplayer.peer_disconnected.disconnect(player_disconnected)
	Signals.set_crosshair.emit(false)
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer.close()
	
	WaitingRoom.hide()
	MainMenu.show()
	$"../CanvasLayer/Background".show()


func player_disconnected(id: int) -> void:
	print("Player disconnected: " + str(id))
	player_disconnected_signal.emit(id)
	if multiplayer.is_server():
		connected_players.erase(id)


func change_player_character(character: int, id: int) -> void:
	if connected_players.has(id):
		connected_players[id]["character"] = character
		print("changed ", id, " character to ", character)
