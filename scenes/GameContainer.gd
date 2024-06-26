extends Node

@onready var MainMenu := %MainMenu
@onready var WaitingRoom := %WaitingRoom
@onready var PlaygroundScene := preload("res://levels/playground/playground.tscn")
@onready var PlayerScene := preload("res://scenes/player/player.tscn")
@onready var MultiplayerManager := $"../MultiplayerManager"
@onready var PlayerSpawner := $"../PlayerSpawner"

var level: Node

func _ready() -> void:
	WaitingRoom.connect("game_started", game_started)
	PlayerSpawner.spawn_function = playerSpawnFunction


func playerSpawnFunction(player_data: Dictionary) -> Node:
	var player := PlayerScene.instantiate()
	player.name = str(player_data.id) # nome do nodo
	player.player_name = player_data.player_name
	player.position = Vector2(400, 500) + player_data.counter * Vector2(700, 0)
	return player


# chamado somente no server
# players são instanciados no server e replicados pelo MultiplayerSpawner
func game_started() -> void:
	level = PlaygroundScene.instantiate()
	add_child(level)
	
	var counter := 0
	print(MultiplayerManager.connected_players)
	
	for id in MultiplayerManager.connected_players:
		var player_data = MultiplayerManager.connected_players[id]
		
		player_data.id = id
		player_data.counter = counter
		# creio que terei que trocar isso aqui por uma spawn function
		# porque não tá sincronizando a posição inicial
		PlayerSpawner.spawn(player_data)
		counter += 1

	game_started_all.rpc()


@rpc("authority", "call_local")
func game_started_all() -> void:
	WaitingRoom.hide()
	$"../CanvasLayer/Background".hide()
	
	
func _on_main_menu_start_playground() -> void:
	var playground := PlaygroundScene.instantiate()
	MainMenu.hide()
	$"../CanvasLayer/Background".hide()
	
	add_child(playground)
	PlayerSpawner.spawn({
		"player_name": "Player",
		"id": 1,
		"counter": 0
	})
