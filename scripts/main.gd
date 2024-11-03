extends Node

var peer = ENetMultiplayerPeer.new()

func _ready():
	peer.create_client("localhost", 9999)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connected():
	print("Connected to server!")

func _on_connection_failed():
	print("Failed to connect!")

@rpc("authority", "call_local", "reliable")
func spawn_player(id: int, pos: Vector3):
	print("Attempting to spawn player: ", id)
	if $World/Players.has_node(str(id)):
		print("Player ", id, " already exists")
		return
		
	var player_scene = preload("res://scenes/player.tscn").instantiate()
	player_scene.name = str(id)
	player_scene.position = pos
	player_scene.set_multiplayer_authority(id)
	$World/Players.add_child(player_scene)
	print("Successfully spawned player ", id, " at position ", pos)

@rpc("authority", "call_local", "reliable")
func despawn_player(id: int):
	if $World/Players.has_node(str(id)):
		$World/Players.get_node(str(id)).queue_free()
		print("Despawned player ", id)
