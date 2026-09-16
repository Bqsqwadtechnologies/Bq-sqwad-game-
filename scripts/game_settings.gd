extends CanvasLayer
class_name BQGameSettings

var panel: PanelContainer
var music_slider: HSlider
var settings_open := false

func _ready() -> void:
    layer = 30
    _build_ui()
    set_process_input(true)
    visible = true
    panel.visible = false

func _build_ui() -> void:
    panel = PanelContainer.new()
    panel.position = Vector2(370, 110)
    panel.size = Vector2(540, 500)
    add_child(panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 28)
    margin.add_theme_constant_override("margin_right", 28)
    margin.add_theme_constant_override("margin_top", 24)
    margin.add_theme_constant_override("margin_bottom", 24)
    panel.add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 16)
    margin.add_child(column)

    var title := Label.new()
    title.text = "BQ SQWAD  /  SETTINGS"
    title.add_theme_font_size_override("font_size", 28)
    column.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "Landly City configuration"
    column.add_child(subtitle)

    var music_label := Label.new()
    music_label.text = "MUSIC VOLUME"
    column.add_child(music_label)

    music_slider = HSlider.new()
    music_slider.min_value = 0.0
    music_slider.max_value = 1.0
    music_slider.step = 0.05
    music_slider.value = 0.8
    music_slider.value_changed.connect(_on_music_volume_changed)
    column.add_child(music_slider)

    var controls := Label.new()
    controls.text = "Controls\nWASD / Arrows  Move\nSPACE  Jump\nE  Interact\nF  Combat\nQ / R  Abilities\nESC  Close settings"
    controls.add_theme_font_size_override("font_size", 16)
    column.add_child(controls)

    var roadmap := Label.new()
    roadmap.text = "WORLD SYSTEMS\n• Dynamic city population\n• Traffic and public zones\n• Vertical landmarks\n• Future character-specific controls"
    roadmap.add_theme_font_size_override("font_size", 15)
    column.add_child(roadmap)

    var close := Button.new()
    close.text = "CLOSE"
    close.custom_minimum_size = Vector2(0, 48)
    close.pressed.connect(close_settings)
    column.add_child(close)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        toggle_settings()

func toggle_settings() -> void:
    settings_open = not settings_open
    panel.visible = settings_open

func close_settings() -> void:
    settings_open = false
    panel.visible = false

func _on_music_volume_changed(value: float) -> void:
    var audio := get_node_or_null("/root/BQGameAudio")
    if audio != null and audio.has_method("set_music_volume"):
        audio.set_music_volume(value)
