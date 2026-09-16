extends CanvasLayer
class_name BQGameSettings

const SETTINGS_PATH := "user://bq_sqwad_settings.cfg"
const DEFAULT_PORT := 24580

var panel: PanelContainer
var music_slider: HSlider
var master_slider: HSlider
var fullscreen_check: CheckButton
var address_edit: LineEdit
var port_edit: LineEdit
var status_label: Label
var settings_open := false
var config := ConfigFile.new()

func _ready() -> void:
    layer = 30
    _load_settings()
    _build_ui()
    set_process_input(true)
    panel.visible = false
    _apply_saved_settings()

func _load_settings() -> void:
    config.load(SETTINGS_PATH)

func _save_settings() -> void:
    config.set_value("audio", "music_volume", music_slider.value if music_slider else 0.8)
    config.set_value("audio", "master_volume", master_slider.value if master_slider else 1.0)
    config.set_value("display", "fullscreen", fullscreen_check.button_pressed if fullscreen_check else false)
    config.save(SETTINGS_PATH)

func _build_ui() -> void:
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.01, 0.02, 0.04, 0.72)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(backdrop)

    panel = PanelContainer.new()
    panel.position = Vector2(285, 70)
    panel.size = Vector2(710, 580)
    add_child(panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 28)
    margin.add_theme_constant_override("margin_right", 28)
    margin.add_theme_constant_override("margin_top", 22)
    margin.add_theme_constant_override("margin_bottom", 22)
    panel.add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 10)
    margin.add_child(column)

    var title := Label.new()
    title.text = "BQ SQWAD  /  SETTINGS"
    title.add_theme_font_size_override("font_size", 28)
    column.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "LANDLY CITY  •  GAME CONFIGURATION"
    subtitle.add_theme_font_size_override("font_size", 13)
    column.add_child(subtitle)

    music_slider = _add_slider(column, "MUSIC VOLUME", 0.0, 1.0, float(config.get_value("audio", "music_volume", 0.8)))
    music_slider.value_changed.connect(_on_music_volume_changed)
    master_slider = _add_slider(column, "MASTER VOLUME", 0.0, 1.0, float(config.get_value("audio", "master_volume", 1.0)))
    master_slider.value_changed.connect(_on_master_volume_changed)

    fullscreen_check = CheckButton.new()
    fullscreen_check.text = "Fullscreen / Expanded Display"
    fullscreen_check.button_pressed = bool(config.get_value("display", "fullscreen", false))
    fullscreen_check.toggled.connect(_on_fullscreen_toggled)
    column.add_child(fullscreen_check)

    var controls := Label.new()
    controls.text = "CONTROLS  •  WASD / ARROWS Move   •   SPACE Jump   •   E Interact   •   F Combat   •   Q / R Abilities   •   M Map   •   ESC Settings"
    controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    controls.add_theme_font_size_override("font_size", 13)
    column.add_child(controls)

    var online_title := Label.new()
    online_title.text = "ONLINE SESSION"
    online_title.add_theme_font_size_override("font_size", 17)
    column.add_child(online_title)

    var online_row := HBoxContainer.new()
    online_row.add_theme_constant_override("separation", 8)
    column.add_child(online_row)

    address_edit = LineEdit.new()
    address_edit.placeholder_text = "Host address / IP"
    address_edit.text = "127.0.0.1"
    address_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    online_row.add_child(address_edit)

    port_edit = LineEdit.new()
    port_edit.placeholder_text = "Port"
    port_edit.text = str(DEFAULT_PORT)
    port_edit.custom_minimum_size = Vector2(110, 0)
    online_row.add_child(port_edit)

    var host := Button.new()
    host.text = "HOST"
    host.pressed.connect(_host_session)
    online_row.add_child(host)

    var join := Button.new()
    join.text = "JOIN"
    join.pressed.connect(_join_session)
    online_row.add_child(join)

    var leave := Button.new()
    leave.text = "LEAVE"
    leave.pressed.connect(_leave_session)
    online_row.add_child(leave)

    status_label = Label.new()
    status_label.text = "OFFLINE"
    status_label.add_theme_font_size_override("font_size", 12)
    column.add_child(status_label)

    var info := Label.new()
    info.text = "PRIVACY  •  Local settings are stored on this device. Online sessions use the network address and port entered by the player. No account system is required for the current offline game."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_theme_font_size_override("font_size", 12)
    column.add_child(info)

    var legal := Label.new()
    legal.text = "© 2026 BQ Sqwad Technologies. BQ Sqwad and Landly City are original game properties of BQ Sqwad Technologies. Made / product of MDSTN, BQ Sqwad Technologies."
    legal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    legal.add_theme_font_size_override("font_size", 12)
    column.add_child(legal)

    var buttons := HBoxContainer.new()
    buttons.alignment = BoxContainer.ALIGNMENT_END
    buttons.add_theme_constant_override("separation", 10)
    column.add_child(buttons)

    var reset := Button.new()
    reset.text = "RESET SETTINGS"
    reset.pressed.connect(_reset_settings)
    buttons.add_child(reset)

    var close := Button.new()
    close.text = "CLOSE"
    close.custom_minimum_size = Vector2(120, 42)
    close.pressed.connect(close_settings)
    buttons.add_child(close)

func _add_slider(parent: VBoxContainer, title_text: String, min_value: float, max_value: float, initial_value: float) -> HSlider:
    var label := Label.new()
    label.text = title_text
    parent.add_child(label)
    var slider := HSlider.new()
    slider.min_value = min_value
    slider.max_value = max_value
    slider.step = 0.05
    slider.value = clamp(initial_value, min_value, max_value)
    parent.add_child(slider)
    return slider

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        toggle_settings()

func toggle_settings() -> void:
    settings_open = not settings_open
    panel.visible = settings_open
    if settings_open:
        _refresh_online_status()

func close_settings() -> void:
    settings_open = false
    panel.visible = false
    _save_settings()

func _on_music_volume_changed(value: float) -> void:
    var audio := get_node_or_null("/root/BQGameAudio")
    if audio != null and audio.has_method("set_music_volume"):
        audio.set_music_volume(value)
    _save_settings()

func _on_master_volume_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(max(value, 0.001)))
    _save_settings()

func _on_fullscreen_toggled(enabled: bool) -> void:
    if enabled:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    _save_settings()

func _apply_saved_settings() -> void:
    _on_master_volume_changed(float(config.get_value("audio", "master_volume", 1.0)))
    var audio := get_node_or_null("/root/BQGameAudio")
    if audio != null and audio.has_method("set_music_volume"):
        audio.set_music_volume(float(config.get_value("audio", "music_volume", 0.8)))
    _on_fullscreen_toggled(bool(config.get_value("display", "fullscreen", false)))

func _host_session() -> void:
    var manager := get_node_or_null("/root/BQMultiplayerManager")
    if manager == null:
        status_label.text = "NETWORK MANAGER UNAVAILABLE"
        return
    var result: int = manager.host(_read_port())
    status_label.text = "HOSTING • PORT %d" % _read_port() if result == OK else "HOST FAILED • %s" % error_string(result)

func _join_session() -> void:
    var manager := get_node_or_null("/root/BQMultiplayerManager")
    if manager == null:
        status_label.text = "NETWORK MANAGER UNAVAILABLE"
        return
    var result: int = manager.join(address_edit.text, _read_port())
    status_label.text = "CONNECTING TO %s" % address_edit.text if result == OK else "JOIN FAILED • %s" % error_string(result)

func _leave_session() -> void:
    var manager := get_node_or_null("/root/BQMultiplayerManager")
    if manager != null:
        manager.leave_session()
    _refresh_online_status()

func _refresh_online_status() -> void:
    var manager := get_node_or_null("/root/BQMultiplayerManager")
    if manager != null and manager.has_method("get_session_state"):
        status_label.text = String(manager.get_session_state())

func _read_port() -> int:
    var value := int(port_edit.text)
    return clamp(value, 1024, 65535)

func _reset_settings() -> void:
    music_slider.value = 0.8
    master_slider.value = 1.0
    fullscreen_check.button_pressed = false
    _save_settings()
    _on_music_volume_changed(0.8)
    _on_master_volume_changed(1.0)
