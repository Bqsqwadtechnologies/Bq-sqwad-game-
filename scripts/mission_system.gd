extends Node

signal mission_changed(title: String, objective: String, xp_reward: int)
signal mission_completed(xp_reward: int)

var active_mission := false
var mission_title := ""
var objective := ""
var xp_reward := 0

func _ready() -> void:
    start_first_mission()

func start_first_mission() -> void:
    active_mission = true
    mission_title = "Signal in Landly City"
    objective = "Reach the mission zone and investigate the signal."
    xp_reward = 100
    mission_changed.emit(mission_title, objective, xp_reward)

func complete_current_mission() -> void:
    if not active_mission:
        return
    active_mission = false
    mission_completed.emit(xp_reward)
