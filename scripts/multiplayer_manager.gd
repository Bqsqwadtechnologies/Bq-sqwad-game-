extends Node
class_name BQMultiplayerManager

## Stage 8 networking foundation.
## Keeps the current single-player game intact while providing a clean
## authority/session layer for future online co-op and multiplayer modes.

signal session_state_changed(state: String)
signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)

const DEFAULT_PORT := 24580
const MAX_CLIENTS := 4

enum SessionState { OFFLINE, HOSTING, CONNECTING, CONNECTED }

var session_state: SessionState = SessionState.OFFLINE
var peer: ENetMultiplayerPeer
var player_peer_ids: Array[int] = []

func _ready() -> void:
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)

func is_online() -> bool:
    return session_state != SessionState.OFFLINE

func is_host() -> bool:
    return multiplayer.is_server() and session_state == SessionState.HOSTING

func host(port: int = DEFAULT_PORT, max_clients: int = MAX_CLIENTS) -> int:
    if is_online():
        return ERR_ALREADY_IN_USE

    peer = ENetMultiplayerPeer.new()
    var result := peer.create_server(port, max_clients)
    if result != OK:
        peer = null
        return result

    multiplayer.multiplayer_peer = peer
    session_state = SessionState.HOSTING
    player_peer_ids = [multiplayer.get_unique_id()]
    session_state_changed.emit("HOSTING")
    return OK

func join(address: String, port: int = DEFAULT_PORT) -> int:
    if is_online():
        return ERR_ALREADY_IN_USE
    if address.strip_edges().is_empty():
        return ERR_INVALID_PARAMETER

    peer = ENetMultiplayerPeer.new()
    var result := peer.create_client(address.strip_edges(), port)
    if result != OK:
        peer = null
        return result

    multiplayer.multiplayer_peer = peer
    session_state = SessionState.CONNECTING
    session_state_changed.emit("CONNECTING")
    return OK

func leave_session() -> void:
    if multiplayer.multiplayer_peer != null:
        multiplayer.multiplayer_peer.close()
    multiplayer.multiplayer_peer = null
    peer = null
    player_peer_ids.clear()
    session_state = SessionState.OFFLINE
    session_state_changed.emit("OFFLINE")

func get_session_state() -> String:
    return SessionState.keys()[session_state]

func get_player_peer_ids() -> Array[int]:
    return player_peer_ids.duplicate()

func _on_peer_connected(peer_id: int) -> void:
    if is_host() and not player_peer_ids.has(peer_id):
        player_peer_ids.append(peer_id)
    peer_joined.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
    player_peer_ids.erase(peer_id)
    peer_left.emit(peer_id)

func _on_connected_to_server() -> void:
    session_state = SessionState.CONNECTED
    player_peer_ids = [multiplayer.get_unique_id()]
    session_state_changed.emit("CONNECTED")

func _on_connection_failed() -> void:
    leave_session()
    session_state_changed.emit("CONNECTION_FAILED")

func _on_server_disconnected() -> void:
    leave_session()
    session_state_changed.emit("SERVER_DISCONNECTED")
