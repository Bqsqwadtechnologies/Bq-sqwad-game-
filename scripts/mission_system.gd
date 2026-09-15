extends Node

signal mission_changed(title: String, objective: String, xp_reward: int)
signal mission_completed(xp_reward: int)

const MISSIONS := [
    {"title": "Signal in Landly City", "objective": "Reach the mission zone and investigate the signal.", "xp": 100, "center": Vector3(38.0, 0.0, 38.0)},
    {"title": "Scout the District", "objective": "Reach the scout position and secure the area.", "xp": 150, "center": Vector3(30.0, 0.0, 32.0)},
    {"title": "Return to BQ Sqwad HQ", "objective": "Return to HQ and report the operation.", "xp": 250, "center": Vector3(0.0, 0.0, 42.0)}
]

var active_mission := false
var mission_index := 0
var mission_title := ""
var objective := ""
var xp_reward := 0
var objective_reached := false

func _ready() -> void:
    start_mission(0)

func start_mission(index: int) -> void:
    mission_index = clampi(index, 0, MISSIONS.size() - 1)
    var mission: Dictionary = MISSIONS[mission_index]
    active_mission = true
    objective_reached = false
    mission_title = String(mission.get("title", "Mission"))
    objective = String(mission.get("objective", "Complete the objective."))
    xp_reward = int(mission.get("xp", 100))
    mission_changed.emit(mission_title, objective, xp_reward)

func start_first_mission() -> void:
    start_mission(0)

func update_player_position(player_position: Vector3) -> void:
    if not active_mission or objective_reached:
        return

    var mission: Dictionary = MISSIONS[mission_index]
    var mission_center: Vector3 = mission.get("center", Vector3.ZERO)
    var distance := Vector2(player_position.x, player_position.z).distance_to(Vector2(mission_center.x, mission_center.z))

    if distance <= 10.0:
        objective_reached = true
        objective = "Objective reached. Press E to complete the mission."
        mission_changed.emit(mission_title, objective, xp_reward)

func complete_current_mission() -> void:
    if not active_mission or not objective_reached:
        return
    active_mission = false
    mission_completed.emit(xp_reward)
    if mission_index + 1 < MISSIONS.size():
        start_mission(mission_index + 1)
