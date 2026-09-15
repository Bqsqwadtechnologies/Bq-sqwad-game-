extends Node
class_name BQProgressionSystem

signal progression_changed(level: int, xp: int, xp_to_next: int)
signal reward_unlocked(reward_id: String, reward_name: String)

const XP_PER_LEVEL := 500
const REWARDS := {
    2: {"id": "ziking_training", "name": "Ziking Training Tier"},
    3: {"id": "advanced_weapons", "name": "Advanced Weapon Tier"},
    4: {"id": "landly_access", "name": "Landly City Access"},
    5: {"id": "hero_rank", "name": "Hero Rank"}
}

var level := 1
var xp := 0
var total_xp := 0
var unlocked_rewards: Array[String] = []

func _ready() -> void:
    progression_changed.emit(level, xp, get_xp_to_next_level())

func add_xp(amount: int) -> void:
    if amount <= 0:
        return
    total_xp += amount
    xp += amount
    while xp >= XP_PER_LEVEL:
        xp -= XP_PER_LEVEL
        level += 1
        _unlock_level_reward(level)
    progression_changed.emit(level, xp, get_xp_to_next_level())

func get_xp_to_next_level() -> int:
    return XP_PER_LEVEL - xp

func get_progress() -> Dictionary:
    return {
        "level": level,
        "xp": xp,
        "total_xp": total_xp,
        "xp_to_next": get_xp_to_next_level(),
        "unlocked_rewards": unlocked_rewards.duplicate()
    }

func _unlock_level_reward(new_level: int) -> void:
    if not REWARDS.has(new_level):
        return
    var reward: Dictionary = REWARDS[new_level]
    var reward_id := String(reward.get("id", ""))
    if reward_id.is_empty() or reward_id in unlocked_rewards:
        return
    unlocked_rewards.append(reward_id)
    reward_unlocked.emit(reward_id, String(reward.get("name", "Reward")))
