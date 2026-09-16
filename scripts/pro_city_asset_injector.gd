extends Node

const CITY_ASSET := "res://assets/world/landly_city/modkit/ModKit_Industrial_Outpost.glb"

var _injected := false

func _process(_delta: float) -> void:
    if _injected:
        return
    var scene := get_tree().current_scene
    if scene == null:
        return
    var city := scene.get_node_or_null("LandlyCity") as Node3D
    if city == null:
        return
    if not ResourceLoader.exists(CITY_ASSET):
        return
    var packed := ResourceLoader.load(CITY_ASSET) as PackedScene
    if packed == null:
        return
    var district := packed.instantiate()
    if not district is Node3D:
        district.queue_free()
        return

    var root := Node3D.new()
    root.name = "LandlyProfessional3DDistrict"
    root.position = Vector3(0, 0, -52)
    root.scale = Vector3(0.78, 0.78, 0.78)
    city.add_child(root)
    root.add_child(district)
    _injected = true
