extends Node
class_name BQCharacterSystem

signal character_changed(character: Dictionary)

# Canonical character registry. Reference photos are visual source-of-truth assets;
# they are not treated as rigged 3D meshes. Each character is ready for a later
# humanoid rig/model import without changing gameplay data.
const ROSTER := [
    {
        "id": "ziking",
        "codename": "Ziking",
        "real_name": "Isaac Umogane",
        "role": "Leader / Controller",
        "faction": "BQ Sqwad",
        "health": 120,
        "speed": 7.0,
        "power": 40,
        "superpowers": ["Control"],
        "abilities": ["Control", "Control Guard"],
        "reference_image": "res://assets/characters/ziking/grok_1789575920234.jpg",
        "visual_reference_is_source_of_truth": true,
        "voice_asset": "res://assets/audio/voices/ziking/voice.ogg",
        "voice_source": "character_voice_or_player_microphone",
        "weapon_slots": 2,
        "weapon_grade": "Advanced",
        "weapon_types": ["Advanced Sidearm", "Advanced Heavy Weapon"],
        "animation_profile": "leader_combat"
    },
    {
        "id": "goodshina",
        "codename": "Goodshina",
        "real_name": "Goodness Umogane",
        "role": "Stealth / Recon",
        "faction": "BQ Sqwad",
        "health": 90,
        "speed": 8.5,
        "power": 35,
        "superpowers": ["Disappearance", "Teleportation", "Yellow Electricity"],
        "abilities": ["Vanish", "Blink", "Electric Strike"],
        "reference_image": "res://assets/characters/goodshina/grok_1789576237435.jpg",
        "visual_reference_is_source_of_truth": true,
        "voice_asset": "res://assets/audio/voices/goodshina/voice.ogg",
        "voice_source": "character_voice_or_player_microphone",
        "weapon_slots": 2,
        "weapon_grade": "Advanced",
        "weapon_types": ["Established Equipment"],
        "animation_profile": "stealth_combat"
    },
    {
        "id": "star",
        "codename": "Star",
        "real_name": "Esther Umogane",
        "role": "Aerial Combat",
        "faction": "BQ Sqwad",
        "health": 100,
        "speed": 9.0,
        "power": 38,
        "superpowers": ["Flight", "Hand Energy", "Enhanced Speed"],
        "abilities": ["Flight", "Energy Burst", "Twin Blade"],
        "reference_image": "res://assets/characters/star/grok_1789574690102.jpg",
        "visual_reference_is_source_of_truth": true,
        "voice_asset": "res://assets/audio/voices/star/voice.ogg",
        "voice_source": "character_voice_or_player_microphone",
        "weapon_slots": 2,
        "weapon_grade": "Advanced",
        "weapon_types": ["Twin Blades"],
        "animation_profile": "aerial_blade_combat",
        "locked_design_areas": ["shirt_front", "logo_marking", "mask"]
    },
    {
        "id": "ella",
        "codename": "Ella",
        "real_name": "Emmanuella Umogane",
        "role": "Technology / Teleportation",
        "faction": "BQ Sqwad",
        "health": 95,
        "speed": 6.5,
        "power": 32,
        "superpowers": ["Ring Teleportation", "Technology Constructs"],
        "abilities": ["Tech Construct", "Ring Teleport"],
        "reference_image": "res://assets/characters/ella/grok_1789576830599.jpg",
        "visual_reference_is_source_of_truth": true,
        "voice_asset": "res://assets/audio/voices/ella/voice.ogg",
        "voice_source": "character_voice_or_player_microphone",
        "weapon_slots": 3,
        "weapon_grade": "Advanced",
        "weapon_types": ["Established Tech Equipment"],
        "animation_profile": "tech_combat"
    },
    {
        "id": "ep",
        "codename": "EP",
        "real_name": "Ephraim Umogane",
        "role": "Speed / Striker",
        "faction": "BQ Sqwad",
        "health": 105,
        "speed": 12.0,
        "power": 34,
        "superpowers": ["Super Speed", "Energy Blade Projection"],
        "abilities": ["Speed Burst", "Blade Shot"],
        "reference_image": "res://assets/characters/ep/grok_1789576589991.jpg",
        "visual_reference_is_source_of_truth": true,
        "voice_asset": "res://assets/audio/voices/ep/voice.ogg",
        "voice_source": "character_voice_or_player_microphone",
        "weapon_slots": 2,
        "weapon_grade": "Advanced",
        "weapon_types": ["Established Firearm Equipment", "Glove Blades"],
        "animation_profile": "speed_combat"
    }
]

var active_character_id := "ziking"
var active_character: Dictionary = ROSTER[0].duplicate(true)

func _ready() -> void:
    character_changed.emit(active_character)

func get_roster() -> Array:
    return ROSTER.duplicate(true)

func select_character(character_id: String) -> bool:
    for character in ROSTER:
        if String(character.get("id", "")) == character_id:
            active_character_id = character_id
            active_character = character.duplicate(true)
            character_changed.emit(active_character)
            return true
    return false

func get_active_character() -> Dictionary:
    return active_character.duplicate(true)

func get_reference_image(character_id: String) -> String:
    for character in ROSTER:
        if String(character.get("id", "")) == character_id:
            return String(character.get("reference_image", ""))
    return ""

func get_voice_asset(character_id: String) -> String:
    for character in ROSTER:
        if String(character.get("id", "")) == character_id:
            return String(character.get("voice_asset", ""))
    return ""
