extends Node

## Persistent player profile used by the real game systems.
## No network service is required; the profile is stored in user:// on Android.

signal profile_changed
signal credits_changed(credits: int)
signal notification_requested(title: String, message: String)

const SAVE_PATH := "user://bq_sqwad_profile.json"
const SAVE_VERSION := 1

var credits: int = 0
var enemies_defeated: int = 0
var missions_completed: int = 0
var damage_dealt: int = 0
var play_time_seconds: float = 0.0
var active_character_id: String = "ziking"
var unlocked_features: Array[String] = []

var _save_timer := 0.0
var _dirty := false

func _ready() -> void:
    load_profile()

func _process(delta: float) -> void:
    play_time_seconds += delta
    _save_timer += delta
    if _dirty and _save_timer >= 5.0:
        save_profile()

func add_credits(amount: int) -> void:
    if amount <= 0:
        return
    credits += amount
    _dirty = true
    credits_changed.emit(credits)
    profile_changed.emit()

func add_enemy_defeat(reward: int, enemy_type: String) -> void:
    enemies_defeated += 1
    add_credits(reward)
    var progression := get_tree().current_scene.get_node_or_null("ProgressionSystem") if get_tree().current_scene else null
    if progression != null and progression.has_method("add_xp"):
        progression.add_xp(max(25, reward * 2))
    notification_requested.emit("ENEMY DEFEATED", "+%d credits  •  %s" % [reward, enemy_type.to_upper()])
    _dirty = true
    profile_changed.emit()

func register_damage(amount: int) -> void:
    if amount <= 0:
        return
    damage_dealt += amount
    _dirty = true

func register_mission_completion(xp_reward: int) -> void:
    missions_completed += 1
    add_credits(max(10, xp_reward / 5))
    notification_requested.emit("MISSION COMPLETE", "+%d XP" % xp_reward)
    _dirty = true
    profile_changed.emit()

func set_active_character(character_id: String) -> void:
    if character_id.is_empty():
        return
    active_character_id = character_id
    _dirty = true
    profile_changed.emit()

func unlock_feature(feature_id: String) -> void:
    if feature_id.is_empty() or feature_id in unlocked_features:
        return
    unlocked_features.append(feature_id)
    _dirty = true
    profile_changed.emit()

func save_profile() -> void:
    var data := {
        "save_version": SAVE_VERSION,
        "credits": credits,
        "enemies_defeated": enemies_defeated,
        "missions_completed": missions_completed,
        "damage_dealt": damage_dealt,
        "play_time_seconds": play_time_seconds,
        "active_character_id": active_character_id,
        "unlocked_features": unlocked_features
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(data))
    file.close()
    _dirty = false
    _save_timer = 0.0

func load_profile() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if not parsed is Dictionary:
        return
    credits = int(parsed.get("credits", 0))
    enemies_defeated = int(parsed.get("enemies_defeated", 0))
    missions_completed = int(parsed.get("missions_completed", 0))
    damage_dealt = int(parsed.get("damage_dealt", 0))
    play_time_seconds = float(parsed.get("play_time_seconds", 0.0))
    active_character_id = String(parsed.get("active_character_id", "ziking"))
    unlocked_features = Array(parsed.get("unlocked_features", []))
    credits_changed.emit(credits)
    profile_changed.emit()

func get_profile() -> Dictionary:
    return {
        "credits": credits,
        "enemies_defeated": enemies_defeated,
        "missions_completed": missions_completed,
        "damage_dealt": damage_dealt,
        "play_time_seconds": play_time_seconds,
        "active_character_id": active_character_id,
        "unlocked_features": unlocked_features.duplicate()
    }
