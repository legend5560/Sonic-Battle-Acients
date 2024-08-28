extends Node

# LAN network test

const DEFAULT_IP = "127.0.0.1"
const PORT = 6007
const MAX_PLAYERS = 4
const DEFAULT_NAME = "player "

var ip = DEFAULT_IP
# web identifier
var id = 0
var player_name = DEFAULT_NAME
# the peer can be either a server or a client
var peer = null
var players = []

# define a signal to update the list of players everytime there is an update to the list
signal list_updated
# signal for when the connection is reseted
signal connection_reseted


func _ready():
	multiplayer.connected_to_server.connect(self.client_connected_to_server)
	multiplayer.connection_failed.connect(self.connection_failure)
	multiplayer.server_disconnected.connect(self.server_disconnected)


# the connection to a server is called when a peer connects to a server so it's only executed from a client
func client_connected_to_server():
	# remote call
	# requires a method to be called and it's parameters
	# when a client connects to a server it means that the connection has being stablished successfully
	# in this case a remote call can be made asking that the server can register the data of the client connected
	# but first get the id
	id = multiplayer.multiplayer_peer.get_unique_id()
	rpc("register_player", id, player_name)


# the peer disconnected is only executed on the server
# the clients won't call peer disconnected because the only peer they are connected to is the server
@rpc("any_peer")
func peer_disconnected(disconnected_id):
	rpc("remove_player", disconnected_id)


# client side connection failure
func connection_failure():
	reset_connection("Client")


# server side connection failure
func server_disconnected():
	# go back to the menu screen
	if not get_tree().current_scene.name == "menu":
		get_tree().change_scene_to_file("res://menu.tscn")
	reset_connection("Server")


func reset_connection(error_message = "Unknown"):
	# rest peer
	peer = null
	# reset multiplayer peer authority
	multiplayer.set_multiplayer_peer(null)
	# reset local players list
	players.clear()
	# emit the signal to update the list
	emit_signal("list_updated")
	emit_signal("connection_reseted", error_message)


@rpc("any_peer")
func register_player(new_id, new_name):
	# when an rpc (remote call) is executed by an object that is the web authority, the call is executed on all peers
	# when an rpc (remote call) is executed by an object that is NOT the authority, the call is executed ONLY on the server
	if multiplayer.is_server():
		# when a new client is registered, all clients must receive an update to the list of players
		# the server will pass to the client that is making this rpc call the list of the clients already connected
		for i in range(players.size()):
			# rpc_id will make a call in a single peer defined by it's id
			rpc_id(new_id, "register_player", players[i][0], players[i][1])
		# the server will make the call for all the clients to register the new registered client
		rpc("register_player", new_id, new_name)
	# the client will only execute this part since the client is not the web authority
	# so the client call will only go to the server
	players.append([new_id, new_name])
	# set the id on globalvariables or change all references to fetch in here (Network)
	GlobalVariables.character_id = id
	# emit a signal to update the list
	emit_signal("list_updated")


# call to remove player in any peer and in the server
@rpc("any_peer", "call_local")
func remove_player(id_to_remove):
	# search for that id in the list of players
	for i in range(players.size()):
		if players[i][0] == id_to_remove:
			# remove the player from the list
			players.remove_at(i)
			# emit the signal to update the list
			emit_signal("list_updated")
			# end this method
			return


# a server is the web authority of all game elements by default
func create_new_server():
	# create a peer
	peer = ENetMultiplayerPeer.new()
	# create a server with the defined port and max number of players
	# check for error
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error != 0:
		print("error creating server")
		reset_connection("Server Creation")
		return
	# check if there is a server
	#var current_ip = return_ip()
	#if current_ip.begins_with("192"):
	# tell godot to use this peer
	multiplayer.set_multiplayer_peer(peer)
	#multiplayer.peer_connected.connect(Instantiables.add_player)
	# the server is the one who should handle the message that a client was disconnected
	peer.peer_disconnected.connect(self.peer_disconnected)
	# the server will also behave as a player so it's data must be registered
	id = multiplayer.multiplayer_peer.get_unique_id()
	# register the server as a player too
	register_player(id, player_name)
	#else:
	#	reset_connection("Server Creation")


func create_new_client():
	# create a peer
	peer = ENetMultiplayerPeer.new()
	# create a client
	# check for error 
	var error = peer.create_client(ip, PORT)
	if error != 0:
		print("error creating client")
		reset_connection("Client Creation")
		return
	# tell godot to use this peer
	multiplayer.set_multiplayer_peer(peer)
	# wait for the connection to be stablished
	await multiplayer.connected_to_server


func update_name(new_name):
	if new_name != "":
		player_name = new_name
	else:
		player_name = DEFAULT_NAME + str(id)


func update_ip(new_ip):
	ip = new_ip


func return_list():
	return players


func return_ip():
	var ip_list = IP.get_local_addresses().duplicate()
	for i in range(ip_list.size()):
		if ip_list[i].begins_with("192"):
			return ip_list[i]
	return DEFAULT_IP


## allow the server to call a method to any peer and local
## only server can call
## the server will call the method for the peers
@rpc("any_peer", "call_local")
func server_call_method(node_to_call_from = self, method_name: String = "", args = null):
	# if peer is setup and this is a server (online and hosting)
	if multiplayer.has_multiplayer_peer() and multiplayer.is_server() and node_to_call_from.has_method(method_name):
		if args != null:
			node_to_call_from.rpc(method_name, args)
		else:
			node_to_call_from.rpc(method_name)
	else:
		# if peer is not setup (offline)
		if multiplayer.has_multiplayer_peer() == false:
			if args != null:
				node_to_call_from.call_deferred(method_name, args)
			else:
				node_to_call_from.call_deferred(method_name)
