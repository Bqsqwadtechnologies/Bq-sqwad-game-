extends Node

signal mission_changed(title: String, objective: String, xp_reward: int)
signal mission_completed(xp_reward: int)

var active_mission := false
var mission_title := ""
var objective := ""
var xp_reward := 0
var objective_reached := false

func _ready() -> void:
    start_first_mission()

func start_first_mission() -> void:
    active_mission = true
    objective_reached = false
    mission_title = "Signal in Landly City"
    objective = "Reach the mission zone and investigate the signal."
    xp_reward = 100
    mission_changed.emit(mission_title, objective, xp_reward)

func update_player_position(player_position: Vector3) -> void:
    if not active_mission:
        return

    var mission_center := Vector3(38.0, 0.0, 38.0)
    var distance := Vector2(player_position.x, player_position.z).distance_to(Vector2(mission_center.x, mission_center.z))

    if not objective_reached and distance <= 10.0:
        objective_reached = true
        objective = "Signal located. Move to the signal marker to complete the investigation."
        mission_changed.emit(mission_title, objective, xp_reward)

    if objective_reached and distance <= 3.0:
        complete_current_mission()

func complete_current_mission() -> void:
    if not active_mission or not objective_reached:
        return
    active_mission = false
    mission_completed.emit(xp_reward)
