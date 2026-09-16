extends CanvasLayer
class_name BQGameSettings

const SETTINGS_PATH := "user://bq_sqwad_settings.cfg"
const DEFAULT_PORT := 24580

var panel: PanelContainer
var music_slider: HSlider
var area_sound_slider: HSlider
var master_slider: HSlider
var fullscreen_check: CheckButton
var night_check: CheckButton
var address_edit: LineEdit
var port_edit: LineEdit
var status_label: Label
var settings_button: Button
var settings_open := false
var config := ConfigFile.new()

func _ready() -> void:
    layer = 50
    _load_settings()
    _build_ui()
    set_process_input(true)
    panel.visible = false
    _apply_saved_settings()
    get_viewport().size_changed.connect(_on_viewport_resized)
    _on_viewport_resized()

func _load_settings() -> void:
    config.load(SETTINGS_PATH)

func _save_settings() -> void:
    config.set_value("audio", "music_volume", music_slider.value if music_slider else 0.8)
    config.set_value("audio", "area_sound_volume", area_sound_slider.value if area_sound_slider else 0.65)
    config.set_value("audio", "master_volume", master_slider.value if master_slider else 1.0)
    config.set_value("display", "fullscreen", fullscreen_check.button_pressed if fullscreen_check else true)
    config.set_value("display", "night_mode", night_check.button_pressed if night_check else false)
    config.save(SETTINGS_PATH)

func _build_ui() -> void:
    var backdrop := ColorRect.new()
    backdrop.name = "SettingsBackdrop"
    backdrop.color = Color(0.005, 0.012, 0.025, 0.78)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(backdrop)

    settings_button = Button.new()
    settings_button.text = "⚙ SETTINGS"
    settings_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    settings_button.size = Vector2(118, 42)
    settings_button.position = Vector2(-135, 242)
    settings_button.pressed.connect(toggle_settings)
    add_child(settings_button)

    panel = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.size = Vector2(710, 610)
    add_child(panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_bottom", 18)
    panel.add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 8)
    margin.add_child(column)

    var title := Label.new()
    title.text = "BQ SQWAD  /  SETTINGS"
    title.add_theme_font_size_override("font_size", 25)
    column.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "LANDLY CITY  •  DISPLAY / AUDIO / ONLINE"
    subtitle.add_theme_font_size_override("font_size", 12)
    column.add_child(subtitle)

    music_slider = _add_slider(column, "MUSIC VOLUME", 0.0, 1.0, float(config.get_value("audio", "music_volume", 0.8)))
    music_slider.value_changed.connect(_on_music_volume_changed)
    area_sound_slider = _add_slider(column, "AREA SOUNDS / AMBIENCE", 0.0, 1.0, float(config.get_value("audio", "area_sound_volume", 0.65)))
    area_sound_slider.value_changed.connect(_on_area_sound_volume_changed)
    master_slider = _add_slider(column, "MASTER VOLUME", 0.0, 1.0, float(config.get_value("audio", "master_volume", 1.0)))
    master_slider.value_changed.connect(_on_master_volume_changed)

    fullscreen_check = CheckButton.new()
    fullscreen_check.text = "Fullscreen / Expanded Display"
    fullscreen_check.button_pressed = bool(config.get_value("display", "fullscreen", true))
    fullscreen_check.toggled.connect(_on_fullscreen_toggled)
    column.add_child(fullscreen_check)

    night_check = CheckButton.new()
    night_check.text = "Night Mode (default world view is late afternoon)"
    night_check.button_pressed = bool(config.get_value("display", "night_mode", false))
    night_check.toggled.connect(_on_night_toggled)
    column.add_child(night_check)

    var controls := Label.new()
    controls.text = "CONTROLS  •  WASD / ARROWS Move   •   SPACE Jump   •   E Interact   •   F Action   •   Q / R Abilities   •   M Map   •   ESC Settings"
    controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    controls.add_theme_font_size_override("font_size", 12)
    column.add_child(controls)

    var online_title := Label.new()
    online_title.text = "ONLINE SESSION"
    online_title.add_theme_font_size_override("font_size", 16)
    column.add_child(online_title)

    var online_row := HBoxContainer.new()
    online_row.add_theme_constant_override("separation", 6)
    online_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    column.add_child(online_row)

    address_edit = LineEdit.new()
    address_edit.placeholder_text = "Host address / IP"
    address_edit.text = "127.0.0.1"
    address_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    online_row.add_child(address_edit)

    port_edit = LineEdit.new()
    port_edit.placeholder_text = "Port"
    port_edit.text = str(DEFAULT_PORT)
    port_edit.custom_minimum_size = Vector2(80, 0)
    online_row.add_child(port_edit)

    for button_text in ["HOST", "JOIN", "LEAVE"]:
        var button := Button.new()
        button.text = button_text
        button.custom_minimum_size = Vector2(76, 38)
        if button_text == "HOST":
            button.pressed.connect(_host_session)
        elif button_text == "JOIN":
            button.pressed.connect(_join_session)
        else:
            button.pressed.connect(_leave_session)
        online_row.add_child(button)

    status_label = Label.new()
    status_label.text = "OFFLINE"
    status_label.add_theme_font_size_override("font_size", 12)
    column.add_child(status_label)

    var info := Label.new()
    info.text = "PRIVACY  •  Local settings are stored on this device. Online sessions use the network address and port entered by the player. No account system is required for the current offline game."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_theme_font_size_override("font_size", 11)
    column.add_child(info)

    var legal := Label.new()
    legal.text = "© 2026 BQ Sqwad Technologies. BQ Sqwad and Landly City are original game properties of BQ Sqwad Technologies. Made / product of MDSTN, BQ Sqwad Technologies."
    legal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    legal.add_theme_font_size_override("font_size", 11)
    column.add_child(legal)

    var buttons := HBoxContainer.new()
    buttons.alignment = BoxContainer.ALIGNMENT_END
    buttons.add_theme_constant_override("separation", 8)
    column.add_child(buttons)

    var reset := Button.new()
    reset.text = "RESET"
    reset.custom_minimum_size = Vector2(100, 40)
    reset.pressed.connect(_reset_settings)
    buttons.add_child(reset)

    var close := Button.new()
    close.text = "CLOSE"
    close.custom_minimum_size = Vector2(110, 40)
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
    slider.custom_minimum_size = Vector2(0, 28)
    slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    parent.add_child(slider)
    return slider

func _on_viewport_resized() -> void:
    if panel == null:
        return
    var viewport_size := get_viewport().size
    var compact := viewport_size.x < 760.0 or viewport_size.y < 680.0
    if compact:
        panel.size = Vector2(max(300.0, viewport_size.x - 28.0), max(420.0, viewport_size.y - 90.0))
        panel.position = Vector2(14, 45)
    else:
        panel.size = Vector2(710, 610)
        panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, (viewport_size.y - panel.size.y) * 0.5)
    if settings_button != null:
        settings_button.position = Vector2(-135, 242)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        toggle_settings()
    elif event is InputEventKey and event.pressed and event.keycode == KEY_N:
        if night_check != null:
            night_check.button_pressed = not night_check.button_pressed

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

func _on_area_sound_volume_changed(value: float) -> void:
    var audio := get_node_or_null("/root/BQGameAudio")
    if audio != null and audio.has_method("set_area_sound_volume"):
        audio.set_area_sound_volume(value)
    _save_settings()

func _on_master_volume_changed(value: float) -> void:
    var master_index := AudioServer.get_bus_index("Master")
    if master_index >= 0:
        AudioServer.set_bus_volume_db(master_index, linear_to_db(max(value, 0.001)))
    _save_settings()

func _on_fullscreen_toggled(enabled: bool) -> void:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)
    _save_settings()

func _on_night_toggled(enabled: bool) -> void:
    var world := get_parent()
    if world != null and world.has_method("set_night_mode"):
        world.set_night_mode(enabled)
    _save_settings()

func _apply_saved_settings() -> void:
    _on_master_volume_changed(float(config.get_value("audio", "master_volume", 1.0)))
    var audio := get_node_or_null("/root/BQGameAudio")
    if audio != null:
        if audio.has_method("set_music_volume"):
            audio.set_music_volume(float(config.get_value("audio", "music_volume", 0.8)))
        if audio.has_method("set_area_sound_volume"):
            audio.set_area_sound_volume(float(config.get_value("audio", "area_sound_volume", 0.65)))
    var night := bool(config.get_value("display", "night_mode", false))
    if night_check != null:
        night_check.button_pressed = night
    _on_fullscreen_toggled(bool(config.get_value("display", "fullscreen", true)))
    _on_night_toggled(night)

func _host_session() -> void:
    var manager := get_node_or_null("/root/BQMultiplayerManager")
    if manager == null:
        status_label.text = "NETWORK MANAGER UNAVAILABLE"
        return
    var port := _read_port()
    var result: int = manager.host(port)
    status_label.text = "HOSTING • PORT %d" % port if result == OK else "HOST FAILED • %s" % error_string(result)

func _join_session() -> void:
    var manager := get_node_or_null("/root/BQMultiplayerManager")
    if manager == null:
        status_label.text = "NETWORK MANAGER UNAVAILABLE"
        return
    var port := _read_port()
    var result: int = manager.join(address_edit.text, port)
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
    area_sound_slider.value = 0.65
    master_slider.value = 1.0
    fullscreen_check.button_pressed = true
    night_check.button_pressed = false
    _save_settings()
    _on_music_volume_changed(0.8)
    _on_area_sound_volume_changed(0.65)
    _on_master_volume_changed(1.0)
    _on_fullscreen_toggled(true)
    _on_night_toggled(false)
