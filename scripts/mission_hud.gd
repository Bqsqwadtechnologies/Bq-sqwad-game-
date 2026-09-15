extends CanvasLayer

@onready var mission_title_label: Label = $Panel/Margin/VBox/MissionTitle
@onready var objective_label: Label = $Panel/Margin/VBox/Objective
@onready var reward_label: Label = $Panel/Margin/VBox/Reward
@onready var status_label: Label = $Panel/Margin/VBox/Status

func _ready() -> void:
    var mission_system := get_parent().get_node_or_null("MissionSystem")
    if mission_system == null:
        return
    mission_system.mission_changed.connect(_on_mission_changed)
    mission_system.mission_completed.connect(_on_mission_completed)
    _on_mission_changed(mission_system.mission_title, mission_system.objective, mission_system.xp_reward)

func _on_mission_changed(title: String, objective: String, xp_reward: int) -> void:
    mission_title_label.text = "MISSION  /  " + title
    objective_label.text = objective
    reward_label.text = "REWARD  •  %d XP" % xp_reward
    status_label.text = "ACTIVE"

func _on_mission_completed(xp_reward: int) -> void:
    status_label.text = "COMPLETE  •  +%d XP" % xp_reward
    objective_label.text = "Mission complete. Return to BQ Sqwad HQ for the next operation."
