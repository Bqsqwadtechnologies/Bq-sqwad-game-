extends Node
class_name BQEnemySystem

signal enemy_spawned(enemy: Node)
signal enemy_defeated(enemy: Node)

# Central enemy definitions. Enemy scenes can consume this data without coupling
# the combat system to one specific mesh or scene implementation.
const ENEMY_TYPES := {
    "street_drone": {
        "display_name": "Street Drone",
        "health": 45,
        "speed": 4.5,
        "damage": 8,
        "attack_range": 12.0,
        "detection_range": 24.0,
        "credits": 5,
        "behavior": "ranged_patrol"
    },
    "city_guard": {
        "display_name": "City Guard",
        "health": 90,
        "speed": 5.0,
        "damage": 14,
        "attack_range": 3.0,
        "detection_range": 30.0,
        "credits": 10,
        "behavior": "melee_pursuit"
    },
    "elite_guard": {
        "display_name": "Elite Guard",
        "health": 160,
        "speed": 5.5,
        "damage": 20,
        "attack_range": 16.0,
        "detection_range": 36.0,
        "credits": 25,
        "behavior": "tactical_ranged"
    },
    "boss": {
        "display_name": "Landly Boss",
        "health": 600,
        "speed": 4.0,
        "damage": 30,
        "attack_range": 18.0,
        "detection_range": 50.0,
        "credits": 100,
        "behavior": "boss_adaptive"
    }
}

var active_enemies: Array[Node] = []

func get_enemy_types() -> Dictionary:
    return ENEMY_TYPES.duplicate(true)

func get_enemy_definition(enemy_type: String) -> Dictionary:
    return ENEMY_TYPES.get(enemy_type, {}).duplicate(true)

func register_enemy(enemy: Node) -> void:
    if enemy == null or active_enemies.has(enemy):
        return
    active_enemies.append(enemy)
    enemy.tree_exited.connect(_on_enemy_exited.bind(enemy), CONNECT_ONE_SHOT)
    enemy_spawned.emit(enemy)

func report_defeated(enemy: Node) -> void:
    if active_enemies.has(enemy):
        active_enemies.erase(enemy)
    enemy_defeated.emit(enemy)

func _on_enemy_exited(enemy: Node) -> void:
    active_enemies.erase(enemy)

func find_nearest_enemy(origin: Vector3, max_distance: float = INF) -> Node3D:
    var nearest: Node3D = null
    var nearest_distance := max_distance
    for candidate in active_enemies:
        if not is_instance_valid(candidate) or not candidate is Node3D:
            continue
        var distance := origin.distance_to((candidate as Node3D).global_position)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest = candidate as Node3D
    return nearest
