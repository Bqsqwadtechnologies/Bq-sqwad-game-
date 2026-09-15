extends RefCounted
class_name AdminCharacterStore

const ADMIN_EMAIL := "isaacoshiomole0@gmail.com"
const CATALOG_PATH := "res://data/characters.json"
const USER_CATALOG_PATH := "user://bq_sqwad_admin/characters.json"

var characters: Array[Dictionary] = []

func load_catalog() -> Array[Dictionary]:
    var path := USER_CATALOG_PATH if FileAccess.file_exists(USER_CATALOG_PATH) else CATALOG_PATH
    if not FileAccess.file_exists(path):
        characters = []
        return characters
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        characters = []
        return characters
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary and parsed.get("characters") is Array:
        characters = []
        for entry in parsed["characters"]:
            if entry is Dictionary:
                characters.append(entry)
    return characters

func save_catalog() -> bool:
    var directory := DirAccess.open("user://")
    if directory != null and not directory.dir_exists("bq_sqwad_admin"):
        directory.make_dir("bq_sqwad_admin")
    var file := FileAccess.open(USER_CATALOG_PATH, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify({"version": 1, "characters": characters}, "  "))
    return true

func upsert_character(character: Dictionary) -> bool:
    var id := String(character.get("id", "")).strip_edges().to_lower().replace(" ", "_")
    if id.is_empty():
        return false
    character["id"] = id
    for index in characters.size():
        if String(characters[index].get("id", "")) == id:
            characters[index] = character
            return save_catalog()
    characters.append(character)
    return save_catalog()

func remove_character(character_id: String) -> bool:
    for index in characters.size():
        if String(characters[index].get("id", "")) == character_id:
            characters.remove_at(index)
            return save_catalog()
    return false

func get_character(character_id: String) -> Dictionary:
    for character in characters:
        if String(character.get("id", "")) == character_id:
            return character.duplicate(true)
    return {}

func import_character_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary and parsed.has("id"):
        return parsed
    if parsed is Dictionary and parsed.get("character") is Dictionary:
        return parsed["character"]
    return {}

func copy_asset(source_path: String, category: String, character_id: String) -> String:
    if source_path.is_empty() or not FileAccess.file_exists(source_path):
        return ""
    var safe_category := category.to_lower().strip_edges().replace(" ", "_")
    var safe_id := character_id.to_lower().strip_edges().replace(" ", "_")
    var source_name := source_path.get_file()
    var target_dir := "user://bq_sqwad_admin/assets/%s/%s" % [safe_category, safe_id]
    DirAccess.make_dir_recursive_absolute(target_dir)
    var target := target_dir.path_join(source_name)
    if DirAccess.copy_absolute(source_path, target) == OK:
        return target
    return ""
