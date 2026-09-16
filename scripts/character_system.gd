extends Node
class_name BQCharacterSystem

signal character_changed(character: Dictionary)

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
        "reference_image": "res://assets/characters/ziking/ziking_reference.jpg",
        "visual_reference_is_source_of_truth": true,
        "weapon_slots": 2,
        "weapon_grade": "Advanced",
        "weapon_types": ["Advanced Sidearm", "Advanced Heavy Weapon"]
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
        "weapon_slots": 2,
        "weapon_grade": "Advanced",
        "weapon_types": ["Established Equipment"]
    },
    {
        "id": "star",
        "codename": "Star",
        "real_name": "Esther Umogane",
        "role": "Aerial Energy",
        "faction": "BQ Sqwad",
        "health": 100,
        "speed": 9.0,
        "power": 38,
        "superpowers": ["Flight", "Hand Lasers", "Enhanced Speed"],
        "abilities": ["Flight", "Laser Burst", "Twin Blade"],
        "reference_image": "res://assets/characters/star/star_reference.png",
        "visual_reference_is_source_of_truth": true,
        "weapon_slots": 2,
        "weapon_grade": "Advanced",
        "weapon_types": ["Twin Blades"]
    },
    {
        "id": "ella",
        "codename": "Ella",
        "real_name": "Emmanuella Umogane",
        "role": "Technology",
        "faction": "BQ Sqwad",
        "health": 95,
        "speed": 6.5,
        "power": 32,
        "superpowers": ["Ring Teleportation"],
        "abilities": ["Tech Construct", "Teleport"],
        "reference_image": "res://assets/characters/ella/ella_reference.png",
        "visual_reference_is_source_of_truth": true,
        "weapon_slots": 3,
        "weapon_grade": "Advanced",
        "weapon_types": ["Established Tech Equipment"]
    },
    {
        "id": "ep",
        "codename": "EP",
        "real_name": "Ephraim Umogane",
        "role": "Speed",
        "faction": "BQ Sqwad",
        "health": 105,
        "speed": 12.0,
        "power": 34,
        "superpowers": ["Super Speed", "Energy Blade Projection"],
        "abilities": ["Speed Burst", "Blade Shot"],
        "reference_image": "res://assets/characters/ep/ep_reference.png",
        "visual_reference_is_source_of_truth": true,
        "weapon_slots": 2,
        "weapon_grade": "Advanced",
        "weapon_types": ["Established Firearm Equipment", "Glove Blades"]
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
