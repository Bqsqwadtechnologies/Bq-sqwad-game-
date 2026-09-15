extends Area3D

@export var interaction_radius := 3.0
var player_inside := false
var completed := false

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
    if player_inside and not completed and Input.is_action_just_pressed("interact"):
        var mission_system := get_parent().get_parent().get_node_or_null("MissionSystem")
        if mission_system != null and mission_system.objective_reached:
            mission_system.complete_current_mission()
            completed = true

func _on_body_entered(body: Node3D) -> void:
    if body.name == "Player" or body.is_in_group("player"):
        player_inside = true

func _on_body_exited(body: Node3D) -> void:
    if body.name == "Player" or body.is_in_group("player"):
        player_inside = false
