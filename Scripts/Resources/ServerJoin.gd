extends Node3D


const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()


func _ready():
	GlobalVariables.server_node = self


func _on_host_button_pressed():
	configure_player()


func configure_player():
	#GlobalVariables.main_menu.online_menu.hide()
	
	if GlobalVariables.character_id == null:
		# need to check if enet already exists
		enet_peer.create_server(PORT)
		# need to check if peer_connect already have a connection
		multiplayer.multiplayer_peer = enet_peer
		multiplayer.peer_connected.connect(Instantiables.add_player)
		# need to check if peer_disconnect already have a connection
		multiplayer.peer_disconnected.connect(remove_player)
		
		# store the character's unique id on gloabal variables to be
		# set in the character after the ability selection is done
		var unique_id = multiplayer.get_unique_id()
		GlobalVariables.character_id = unique_id
	
	# call the next menu window in the menu script
	GlobalVariables.main_menu.after_online_setup()


func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()


func _on_join_button_pressed():
	GlobalVariables.main_menu.online_menu.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

