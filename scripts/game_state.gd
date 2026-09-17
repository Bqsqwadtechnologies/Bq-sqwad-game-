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
var _hud_label: Label
var _notice_label: Label
var _notice_timer := 0.0

func _ready() -> void:
    load_profile()
    call_deferred("_connect_runtime_systems")
    call_deferred("_create_profile_hud")

func _process(delta: float) -> void:
    play_time_seconds += delta
    _save_timer += delta
    if _notice_timer > 0.0:
        _notice_timer = max(0.0, _notice_timer - delta)
        if _notice_timer <= 0.0 and is_instance_valid(_notice_label):
            _notice_label.visible = false
    if _dirty and _save_timer >= 5.0:
        save_profile()

func _connect_runtime_systems() -> void:
    if has_node("/root/BQEnemySystem") and not BQEnemySystem.enemy_defeated.is_connected(_on_enemy_defeated):
        BQEnemySystem.enemy_defeated.connect(_on_enemy_defeated)
    var scene := get_tree().current_scene
    if scene != null:
        var mission_system := scene.get_node_or_null("MissionSystem")
        if mission_system != null and mission_system.has_signal("mission_completed") and not mission_system.mission_completed.is_connected(_on_mission_completed):
            mission_system.mission_completed.connect(_on_mission_completed)

func _create_profile_hud() -> void:
    var scene := get_tree().current_scene
    if scene == null:
        return
    var layer := CanvasLayer.new()
    layer.name = "ProfileHUD"
    scene.add_child(layer)
    _hud_label = Label.new()
    _hud_label.position = Vector2(930, 22)
    _hud_label.size = Vector2(320, 70)
    _hud_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    _hud_label.add_theme_font_size_override("font_size", 16)
    _hud_label.add_theme_color_override("font_color", Color(0.65, 0.9, 1.0))
    layer.add_child(_hud_label)
    _notice_label = Label.new()
    _notice_label.position = Vector2(430, 620)
    _notice_label.size = Vector2(420, 60)
    _notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _notice_label.add_theme_font_size_override("font_size", 17)
    _notice_label.add_theme_color_override("font_color", Color(0.75, 0.93, 1.0))
    _notice_label.visible = false
    layer.add_child(_notice_label)
    credits_changed.connect(_refresh_hud)
    profile_changed.connect(_refresh_hud)
    notification_requested.connect(_show_notification)
    _refresh_hud()

func _refresh_hud(_unused = null) -> void:
    if not is_instance_valid(_hud_label):
        return
    var hours := int(play_time_seconds) / 3600
    var minutes := (int(play_time_seconds) % 3600) / 60
    _hud_label.text = "CREDITS  %d\nLVL PROFILE  •  %02d:%02d" % [credits, hours, minutes]

func _show_notification(title: String, message: String) -> void:
    if not is_instance_valid(_notice_label):
        return
    _notice_label.text = "%s\n%s" % [title, message]
    _notice_label.visible = true
    _notice_timer = 3.0

func _on_enemy_defeated(enemy: Node) -> void:
    if enemy == null:
        return
    var enemy_type := String(enemy.get("enemy_type"))
    var definition := BQEnemySystem.get_enemy_definition(enemy_type)
    var reward := int(definition.get("credits", 0))
    add_enemy_defeat(reward, enemy_type)

func _on_mission_completed(xp_reward: int) -> void:
    register_mission_completion(xp_reward)

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
    var scene := get_tree().current_scene
    var progression := scene.get_node_or_null("ProgressionSystem") if scene else null
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
