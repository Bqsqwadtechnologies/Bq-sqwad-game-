extends CanvasLayer
class_name BQCityMap

var map_panel: Panel
var full_map: Control

func _ready() -> void:
    layer = 20
    _build_ui()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("map"):
        _toggle_full_map()

func _build_ui() -> void:
    map_panel = Panel.new()
    map_panel.position = Vector2(1030, 24)
    map_panel.size = Vector2(220, 150)
    add_child(map_panel)

    var title := Label.new()
    title.position = Vector2(12, 8)
    title.text = "LANDLY CITY  •  MAP"
    title.add_theme_font_size_override("font_size", 14)
    map_panel.add_child(title)

    var map := ColorRect.new()
    map.position = Vector2(12, 34)
    map.size = Vector2(196, 100)
    map.color = Color(0.035, 0.065, 0.10, 0.96)
    map_panel.add_child(map)

    _road(map, Vector2(98, 0), Vector2(10, 100))
    _road(map, Vector2(0, 48), Vector2(196, 10))
    _marker(map, Vector2(98, 86), "S", Color(0.25, 0.75, 1.0))
    _marker(map, Vector2(98, 74), "H", Color(0.35, 0.85, 1.0))
    _marker(map, Vector2(157, 74), "M", Color(0.95, 0.35, 0.75))
    _marker(map, Vector2(41, 74), "T", Color(0.95, 0.75, 0.2))
    _marker(map, Vector2(27, 25), "C", Color(0.55, 0.85, 1.0))
    _marker(map, Vector2(178, 20), "A", Color(0.65, 0.75, 0.65))

    var hint := Label.new()
    hint.position = Vector2(12, 136)
    hint.text = "M  Open city map"
    hint.add_theme_font_size_override("font_size", 11)
    map_panel.add_child(hint)

func _road(parent: Control, position: Vector2, size: Vector2) -> void:
    var road := ColorRect.new()
    road.position = position - size * 0.5
    road.size = size
    road.color = Color(0.12, 0.14, 0.18, 1)
    parent.add_child(road)

func _marker(parent: Control, position: Vector2, text_value: String, tint: Color) -> void:
    var marker := Label.new()
    marker.text = text_value
    marker.position = position - Vector2(5, 8)
    marker.add_theme_font_size_override("font_size", 14)
    marker.modulate = tint
    parent.add_child(marker)

func _toggle_full_map() -> void:
    if full_map == null:
        _create_full_map()
    full_map.visible = not full_map.visible

func _create_full_map() -> void:
    full_map = ColorRect.new()
    full_map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    full_map.color = Color(0.01, 0.025, 0.055, 0.97)
    add_child(full_map)

    var title := Label.new()
    title.position = Vector2(70, 45)
    title.text = "LANDLY CITY  /  PUBLIC MAP"
    title.add_theme_font_size_override("font_size", 28)
    full_map.add_child(title)

    var map := ColorRect.new()
    map.position = Vector2(70, 105)
    map.size = Vector2(1140, 520)
    map.color = Color(0.025, 0.055, 0.085, 1)
    full_map.add_child(map)

    _road(map, Vector2(570, 260), Vector2(18, 520))
    _road(map, Vector2(570, 260), Vector2(1140, 18))
    _road(map, Vector2(570, 120), Vector2(10, 520))
    _road(map, Vector2(570, 400), Vector2(1140, 10))

    _big_marker(map, Vector2(570, 430), "SPAWN")
    _big_marker(map, Vector2(570, 360), "BQ SQWAD HQ")
    _big_marker(map, Vector2(860, 360), "MISSION")
    _big_marker(map, Vector2(280, 360), "TRAINING")
    _big_marker(map, Vector2(230, 90), "LANDLY COLLEGE")
    _big_marker(map, Vector2(1030, 80), "MILITARY ZONE")
    _big_marker(map, Vector2(170, 470), "LANDLY TOWER")

    var footer := Label.new()
    footer.position = Vector2(70, 650)
    footer.text = "M  Close map    •    S Spawn    •    H HQ    •    T Training    •    C College    •    A Military Air"
    footer.add_theme_font_size_override("font_size", 14)
    footer.modulate = Color(0.65, 0.8, 0.92)
    full_map.add_child(footer)

func _big_marker(parent: Control, position: Vector2, text_value: String) -> void:
    var marker := Label.new()
    marker.text = "◆  " + text_value
    marker.position = position
    marker.add_theme_font_size_override("font_size", 18)
    marker.modulate = Color(0.55, 0.85, 1.0)
    parent.add_child(marker)
