extends Node

signal profile_changed
signal credits_changed(credits: int)
signal notification_requested(title: String, message: String)

const SAVE_PATH := "user://bq_sqwad_profile.json"
const SAVE_VERSION := 2

var credits := 0
var enemies_defeated := 0
var missions_completed := 0
var damage_dealt := 0
var play_time_seconds := 0.0
var active_character_id := "ziking"
var unlocked_features: Array[String] = []
var progression_level := 1
var progression_xp := 0
var progression_total_xp := 0
var progression_rewards: Array[String] = []
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
        if _notice_timer <= 0.0 and is_instance_valid(_notice_label): _notice_label.visible = false
    if _dirty and _save_timer >= 5.0: save_profile()

func _connect_runtime_systems() -> void:
    if has_node("/root/BQEnemySystem") and not BQEnemySystem.enemy_defeated.is_connected(_on_enemy_defeated):
        BQEnemySystem.enemy_defeated.connect(_on_enemy_defeated)
    var scene := get_tree().current_scene
    if scene == null: return
    var mission_system := scene.get_node_or_null("MissionSystem")
    if mission_system != null and mission_system.has_signal("mission_completed") and not mission_system.mission_completed.is_connected(_on_mission_completed):
        mission_system.mission_completed.connect(_on_mission_completed)
    var progression := scene.get_node_or_null("ProgressionSystem") as BQProgressionSystem
    if progression != null:
        progression.level = progression_level
        progression.xp = progression_xp
        progression.total_xp = progression_total_xp
        progression.unlocked_rewards = progression_rewards.duplicate()
        if not progression.progression_changed.is_connected(_on_progression_changed): progression.progression_changed.connect(_on_progression_changed)
        if not progression.reward_unlocked.is_connected(_on_reward_unlocked): progression.reward_unlocked.connect(_on_reward_unlocked)
        progression.progression_changed.emit(progression.level, progression.xp, progression.get_xp_to_next_level())

func _create_profile_hud() -> void:
    var scene := get_tree().current_scene
    if scene == null: return
    var layer := CanvasLayer.new()
    layer.name = "ProfileHUD"
    scene.add_child(layer)
    _hud_label = Label.new()
    _hud_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    _hud_label.position = Vector2(-300, 18)
    _hud_label.size = Vector2(280, 70)
    _hud_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    _hud_label.add_theme_font_size_override("font_size", 15)
    _hud_label.add_theme_color_override("font_color", Color(0.65,0.9,1.0))
    layer.add_child(_hud_label)
    _notice_label = Label.new()
    _notice_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    _notice_label.position = Vector2(-260,-150)
    _notice_label.size = Vector2(520,70)
    _notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _notice_label.add_theme_font_size_override("font_size",17)
    _notice_label.visible = false
    layer.add_child(_notice_label)
    credits_changed.connect(_refresh_hud)
    profile_changed.connect(_refresh_hud)
    notification_requested.connect(_show_notification)
    _refresh_hud()

func _refresh_hud(_unused = null) -> void:
    if not is_instance_valid(_hud_label): return
    var hours := int(play_time_seconds) / 3600
    var minutes := (int(play_time_seconds) % 3600) / 60
    _hud_label.text = "CREDITS  %d\nLEVEL  %d  •  XP %d/%d\nTIME  %02d:%02d" % [credits, progression_level, progression_xp, 500, hours, minutes]

func _show_notification(title: String, message: String) -> void:
    if not is_instance_valid(_notice_label): return
    _notice_label.text = "%s\n%s" % [title, message]
    _notice_label.visible = true
    _notice_timer = 3.0

func _on_enemy_defeated(enemy: Node) -> void:
    if enemy == null: return
    var definition := BQEnemySystem.get_enemy_definition(String(enemy.get("enemy_type")))
    add_enemy_defeat(int(definition.get("credits",0)), String(enemy.get("enemy_type")))

func _on_mission_completed(xp_reward: int) -> void: register_mission_completion(xp_reward)

func _on_progression_changed(level: int, current_xp: int, _xp_to_next: int) -> void:
    progression_level = level
    progression_xp = current_xp
    _dirty = true
    profile_changed.emit()

func _on_reward_unlocked(reward_id: String, reward_name: String) -> void:
    if reward_id not in progression_rewards: progression_rewards.append(reward_id)
    notification_requested.emit("UNLOCKED", reward_name)
    _dirty = true

func add_credits(amount: int) -> void:
    if amount <= 0: return
    credits += amount
    _dirty = true
    credits_changed.emit(credits)
    profile_changed.emit()

func add_enemy_defeat(reward: int, enemy_type: String) -> void:
    enemies_defeated += 1
    add_credits(reward)
    var scene := get_tree().current_scene
    var progression := scene.get_node_or_null("ProgressionSystem") if scene else null
    if progression != null and progression.has_method("add_xp"): progression.add_xp(max(25,reward*2))
    notification_requested.emit("ENEMY DEFEATED", "+%d credits  •  %s" % [reward,enemy_type.to_upper()])
    _dirty = true
    profile_changed.emit()

func register_damage(amount: int) -> void:
    if amount <= 0: return
    damage_dealt += amount
    _dirty = true

func register_mission_completion(xp_reward: int) -> void:
    missions_completed += 1
    add_credits(max(10,xp_reward/5))
    var progression := get_tree().current_scene.get_node_or_null("ProgressionSystem")
    if progression != null and progression.has_method("add_xp"): progression.add_xp(xp_reward)
    notification_requested.emit("MISSION COMPLETE", "+%d XP" % xp_reward)
    _dirty = true
    profile_changed.emit()

func set_active_character(character_id: String) -> void:
    if character_id.is_empty(): return
    active_character_id = character_id
    _dirty = true
    profile_changed.emit()

func unlock_feature(feature_id: String) -> void:
    if feature_id.is_empty() or feature_id in unlocked_features: return
    unlocked_features.append(feature_id)
    _dirty = true
    profile_changed.emit()

func save_profile() -> void:
    var data := {"save_version":SAVE_VERSION,"credits":credits,"enemies_defeated":enemies_defeated,"missions_completed":missions_completed,"damage_dealt":damage_dealt,"play_time_seconds":play_time_seconds,"active_character_id":active_character_id,"unlocked_features":unlocked_features,"progression_level":progression_level,"progression_xp":progression_xp,"progression_total_xp":progression_total_xp,"progression_rewards":progression_rewards}
    var file := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    if file == null: return
    file.store_string(JSON.stringify(data)); file.close()
    _dirty = false; _save_timer = 0.0

func load_profile() -> void:
    if not FileAccess.file_exists(SAVE_PATH): return
    var file := FileAccess.open(SAVE_PATH,FileAccess.READ)
    if file == null: return
    var parsed = JSON.parse_string(file.get_as_text()); file.close()
    if not parsed is Dictionary: return
    credits=int(parsed.get("credits",0)); enemies_defeated=int(parsed.get("enemies_defeated",0)); missions_completed=int(parsed.get("missions_completed",0)); damage_dealt=int(parsed.get("damage_dealt",0)); play_time_seconds=float(parsed.get("play_time_seconds",0.0)); active_character_id=String(parsed.get("active_character_id","ziking")); unlocked_features=Array(parsed.get("unlocked_features",[])); progression_level=int(parsed.get("progression_level",1)); progression_xp=int(parsed.get("progression_xp",0)); progression_total_xp=int(parsed.get("progression_total_xp",0)); progression_rewards=Array(parsed.get("progression_rewards",[]))
    credits_changed.emit(credits); profile_changed.emit()

func get_profile() -> Dictionary:
    return {"credits":credits,"enemies_defeated":enemies_defeated,"missions_completed":missions_completed,"damage_dealt":damage_dealt,"play_time_seconds":play_time_seconds,"active_character_id":active_character_id,"unlocked_features":unlocked_features.duplicate(),"progression_level":progression_level,"progression_xp":progression_xp,"progression_total_xp":progression_total_xp,"progression_rewards":progression_rewards.duplicate()}
