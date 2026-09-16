extends CanvasLayer
class_name BQCityMap

var map_panel: PanelContainer
var map_surface: Control
var player_pin: Label
var player_ring: Label
var full_map: Control
var full_map_surface: Control
var full_player_pin: Label
var map_button: Button
var expanded := false

const WORLD_HALF := 60.0
const MAP_SIZE := 170.0
const MAP_CENTER := Vector2(MAP_SIZE * 0.5, MAP_SIZE * 0.5)

const POINTS := [
    {"pos": Vector3(0, 0, -34), "label": "S", "name": "SPAWN"},
    {"pos": Vector3(0, 0, 42), "label": "H", "name": "HQ"},
    {"pos": Vector3(38, 0, 38), "label": "M", "name": "MISSION"},
    {"pos": Vector3(-38, 0, 38), "label": "T", "name": "TRAINING"},
    {"pos": Vector3(-58, 0, -42), "label": "C", "name": "COLLEGE"},
    {"pos": Vector3(55, 0, -48), "label": "D", "name": "DEFENCE"},
    {"pos": Vector3(-55, 0, 45), "label": "V", "name": "VILLAS"}
]

func _ready() -> void:
    layer = 40
    _build_ui()
    set_process(true)

func _process(_delta: float) -> void:
    var player := get_node_or_null("../Player") as Node3D
    if player == null:
        return
    var world_position := player.global_position
    _update_player_pin(world_position)

func _build_ui() -> void:
    map_panel = PanelContainer.new()
    map_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    map_panel.position = Vector2(-205, 18)
    map_panel.size = Vector2(188, 214)
    add_child(map_panel)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 5)
    map_panel.add_child(column)

    var title := Label.new()
    title.text = "LANDLY CITY"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 14)
    column.add_child(title)

    map_surface = Control.new()
    map_surface.custom_minimum_size = Vector2(MAP_SIZE, MAP_SIZE)
    map_surface.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    column.add_child(map_surface)
    _build_circular_surface(map_surface)

    var hint := Label.new()
    hint.text = "MAP  •  live position"
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.add_theme_font_size_override("font_size", 10)
    column.add_child(hint)

    map_button = Button.new()
    map_button.text = "MAP"
    map_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    map_button.position = Vector2(-105, 242)
    map_button.size = Vector2(88, 40)
    map_button.pressed.connect(_toggle_full_map)
    add_child(map_button)

func _build_circular_surface(surface: Control) -> void:
    var circle := Label.new()
    circle.text = "●"
    circle.position = Vector2(2, 2)
    circle.size = Vector2(MAP_SIZE - 4, MAP_SIZE - 4)
    circle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    circle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    circle.add_theme_font_size_override("font_size", 150)
    circle.modulate = Color(0.025, 0.055, 0.09, 0.98)
    circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
    surface.add_child(circle)

    # Roads are drawn as a compact symbolic representation of the actual 120m city.
    _road(surface, Vector2(MAP_SIZE * 0.5, 4), Vector2(7, MAP_SIZE - 8))
    _road(surface, Vector2(4, MAP_SIZE * 0.5), Vector2(MAP_SIZE - 8, 7))
    _road(surface, Vector2(MAP_SIZE * 0.5, MAP_SIZE * 0.20), Vector2(4, MAP_SIZE * 0.60))
    _road(surface, Vector2(MAP_SIZE * 0.80, MAP_SIZE * 0.5), Vector2(MAP_SIZE * 0.60, 4))

    for point in POINTS:
        _place_point(surface, point["pos"], point["label"], point["name"])

    player_ring = Label.new()
    player_ring.text = "◎"
    player_ring.size = Vector2(30, 30)
    player_ring.add_theme_font_size_override("font_size", 27)
    player_ring.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    player_ring.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    player_ring.modulate = Color(0.35, 0.9, 1.0)
    player_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
    surface.add_child(player_ring)

    player_pin = Label.new()
    player_pin.text = "●"
    player_pin.size = Vector2(24, 24)
    player_pin.add_theme_font_size_override("font_size", 18)
    player_pin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    player_pin.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    player_pin.modulate = Color(0.75, 0.95, 1.0)
    player_pin.mouse_filter = Control.MOUSE_FILTER_IGNORE
    surface.add_child(player_pin)

func _place_point(surface: Control, world: Vector3, label_text: String, point_name: String) -> void:
    var marker := Label.new()
    marker.text = label_text
    marker.tooltip_text = point_name
    marker.size = Vector2(22, 22)
    marker.position = _world_to_map(world) - Vector2(11, 11)
    marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    marker.add_theme_font_size_override("font_size", 12)
    marker.modulate = Color(0.68, 0.82, 0.95)
    marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    surface.add_child(marker)

func _world_to_map(world: Vector3) -> Vector2:
    return Vector2(
        clamp((world.x / WORLD_HALF + 1.0) * 0.5 * MAP_SIZE, 8.0, MAP_SIZE - 8.0),
        clamp((world.z / WORLD_HALF + 1.0) * 0.5 * MAP_SIZE, 8.0, MAP_SIZE - 8.0)
    )

func _update_player_pin(world_position: Vector3) -> void:
    var point := _world_to_map(world_position)
    if player_pin != null:
        player_pin.position = point - Vector2(12, 12)
    if player_ring != null:
        player_ring.position = point - Vector2(15, 15)
    if full_player_pin != null:
        full_player_pin.position = _world_to_full_map(world_position) - Vector2(12, 12)

func _road(parent: Control, position: Vector2, size: Vector2) -> void:
    var road := ColorRect.new()
    road.position = position - size * 0.5
    road.size = size
    road.color = Color(0.16, 0.18, 0.22, 0.95)
    road.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(road)

func _toggle_full_map() -> void:
    if full_map == null:
        _create_full_map()
    expanded = not expanded
    full_map.visible = expanded

func _create_full_map() -> void:
    full_map = ColorRect.new()
    full_map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    full_map.color = Color(0.006, 0.016, 0.035, 0.98)
    add_child(full_map)

    var title := Label.new()
    title.set_anchors_preset(Control.PRESET_TOP_WIDE)
    title.position = Vector2(0, 26)
    title.size = Vector2(0, 44)
    title.text = "LANDLY CITY  /  CITY NAVIGATION"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 26)
    full_map.add_child(title)

    full_map_surface = Control.new()
    full_map_surface.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    full_map_surface.position = Vector2(-min(470.0, get_viewport().size.x * 0.39), -min(300.0, get_viewport().size.y * 0.34))
    full_map_surface.size = Vector2(min(940.0, get_viewport().size.x * 0.78), min(600.0, get_viewport().size.y * 0.68))
    full_map.add_child(full_map_surface)

    var background := ColorRect.new()
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.color = Color(0.025, 0.065, 0.10, 1)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    full_map_surface.add_child(background)

    _road(full_map_surface, full_map_surface.size * Vector2(0.5, 0.5), Vector2(10, full_map_surface.size.y - 20))
    _road(full_map_surface, full_map_surface.size * Vector2(0.5, 0.5), Vector2(full_map_surface.size.x - 20, 10))
    _road(full_map_surface, Vector2(full_map_surface.size.x * 0.2, full_map_surface.size.y * 0.5), Vector2(4, full_map_surface.size.y))
    _road(full_map_surface, Vector2(full_map_surface.size.x * 0.8, full_map_surface.size.y * 0.5), Vector2(4, full_map_surface.size.y))
    _road(full_map_surface, Vector2(full_map_surface.size.x * 0.5, full_map_surface.size.y * 0.2), Vector2(full_map_surface.size.x, 4))
    _road(full_map_surface, Vector2(full_map_surface.size.x * 0.5, full_map_surface.size.y * 0.8), Vector2(full_map_surface.size.x, 4))

    for point in POINTS:
        _place_full_point(point["pos"], point["label"], point["name"])

    full_player_pin = Label.new()
    full_player_pin.text = "●"
    full_player_pin.size = Vector2(24, 24)
    full_player_pin.add_theme_font_size_override("font_size", 20)
    full_player_pin.modulate = Color(0.55, 0.95, 1.0)
    full_player_pin.mouse_filter = Control.MOUSE_FILTER_IGNORE
    full_map_surface.add_child(full_player_pin)

    var close := Button.new()
    close.text = "CLOSE MAP"
    close.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    close.position = Vector2(-150, -58)
    close.size = Vector2(130, 42)
    close.pressed.connect(_toggle_full_map)
    full_map.add_child(close)

    full_map.visible = false

func _place_full_point(world: Vector3, label_text: String, point_name: String) -> void:
    var marker := Label.new()
    marker.text = "◆ " + label_text + "  " + point_name
    marker.position = _world_to_full_map(world)
    marker.add_theme_font_size_override("font_size", 14)
    marker.modulate = Color(0.65, 0.86, 1.0)
    marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    full_map_surface.add_child(marker)

func _world_to_full_map(world: Vector3) -> Vector2:
    var size := full_map_surface.size
    return Vector2(
        clamp((world.x / WORLD_HALF + 1.0) * 0.5 * size.x, 12.0, size.x - 12.0),
        clamp((world.z / WORLD_HALF + 1.0) * 0.5 * size.y, 12.0, size.y - 12.0)
    )
