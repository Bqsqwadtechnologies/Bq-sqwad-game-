extends Node
class_name BQCharacterSystem

signal character_changed(character: Dictionary)

const ROSTER := [
    {"id":"ziking", "codename":"Ziking", "real_name":"Isaac Umogane", "role":"Leader", "faction":"BQ Sqwad", "health":120, "speed":7.0, "power":25, "abilities":["Command", "Combat"]},
    {"id":"star", "codename":"Star", "real_name":"Esther Umogane", "role":"Aerial Energy", "faction":"BQ Sqwad", "health":100, "speed":8.0, "power":30, "abilities":["Flight", "Energy"]},
    {"id":"ella", "codename":"Ella", "real_name":"Emmanuella Umogane", "role":"Technology", "faction":"BQ Sqwad", "health":95, "speed":6.5, "power":22, "abilities":["Control", "Tech"]},
    {"id":"ep", "codename":"EP", "real_name":"Ephraim Umogane", "role":"Speed", "faction":"BQ Sqwad", "health":105, "speed":10.0, "power":24, "abilities":["Speed", "Electric"]},
    {"id":"goodshina", "codename":"Goodshina", "real_name":"Goodness Umogane", "role":"Stealth", "faction":"BQ Sqwad", "health":90, "speed":8.5, "power":26, "abilities":["Disappearance", "Stealth"]}
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
