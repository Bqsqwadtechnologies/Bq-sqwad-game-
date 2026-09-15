extends CanvasLayer

@onready var mission_title: Label = $MissionPanel/MissionTitle
@onready var mission_objective: Label = $MissionPanel/MissionObjective
@onready var mission_status: Label = $MissionPanel/MissionStatus
@onready var xp_label: Label = $StatsPanel/XP
@onready var location_label: Label = $LocationLabel

var xp := 0

func _ready() -> void:
    var mission_system := get_parent().get_node_or_null("MissionSystem")
    if mission_system != null:
        mission_system.mission_changed.connect(_on_mission_changed)
        mission_system.mission_completed.connect(_on_mission_completed)
        _on_mission_changed(mission_system.mission_title, mission_system.objective, mission_system.xp_reward)

func _process(_delta: float) -> void:
    var player := get_parent().get_node_or_null("Player")
    if player != null:
        location_label.text = "LANDLY CITY  //  %s" % _district_name(player.global_position)

func _on_mission_changed(title: String, objective: String, reward: int) -> void:
    mission_title.text = title
    mission_objective.text = objective
    mission_status.text = "REWARD  %d XP" % reward

func _on_mission_completed(reward: int) -> void:
    xp += reward
    xp_label.text = "XP  %d" % xp
    mission_status.text = "MISSION COMPLETE  •  +%d XP" % reward

func _district_name(position: Vector3) -> String:
    if position.z > 30.0 and abs(position.x) < 20.0:
        return "BQ SQWAD HQ"
    if position.x < -20.0 and position.z > 20.0:
        return "TRAINING DISTRICT"
    if position.x > 20.0 and position.z > 20.0:
        return "SIGNAL DISTRICT"
    if abs(position.x) < 12.0 or abs(position.z) < 12.0:
        return "CENTRAL AVENUE"
    return "LANDLY CITY"
