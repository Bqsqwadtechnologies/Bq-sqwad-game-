extends Node
class_name BQGameAudio

## Landly City audio layer.
## Uploaded .m4a files are converted to temporary .ogg files by the Android build workflow;
## the runtime itself only loads Godot-supported imported audio formats.
## Area music and environmental ambience use separate audio buses and controls.

const AREA_ZONES := [
    {"id": "downtown", "center": Vector3(0, 0, 0), "radius": 42.0},
    {"id": "college", "center": Vector3(-58, 0, -42), "radius": 28.0},
    {"id": "training", "center": Vector3(-38, 0, 38), "radius": 28.0},
    {"id": "mission", "center": Vector3(38, 0, 38), "radius": 28.0},
    {"id": "military", "center": Vector3(55, 0, -48), "radius": 30.0},
    {"id": "hq", "center": Vector3(0, 0, 42), "radius": 24.0}
]

const AUDIO_EXTENSIONS := [".ogg", ".wav", ".mp3"]
const MUSIC_FADE_SECONDS := 0.8

var music_player: AudioStreamPlayer
var area_player: AudioStreamPlayer
var player: Node3D
var current_area := ""
var music_volume := 0.8
var area_sound_volume := 0.65
var music_cache: Dictionary = {}
var ambient_cache: Dictionary = {}
var ambience_emitters: Array[AudioStreamPlayer3D] = []
var ambience_timer := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    _ensure_audio_buses()

    music_player = AudioStreamPlayer.new()
    music_player.name = "MusicPlayer"
    music_player.bus = "Music"
    add_child(music_player)
    music_player.finished.connect(_on_music_finished.bind(music_player))

    area_player = AudioStreamPlayer.new()
    area_player.name = "AreaMusicPlayer"
    area_player.bus = "Music"
    add_child(area_player)
    area_player.finished.connect(_on_music_finished.bind(area_player))

    _discover_music()
    _discover_ambient_audio()
    _create_city_ambient_emitters()
    set_music_volume(music_volume)
    set_area_sound_volume(area_sound_volume)
    _play_opening_music()

func _process(delta: float) -> void:
    if player == null:
        player = get_tree().get_first_node_in_group("player") as Node3D
    if player != null:
        _update_area_music(player.global_position)
        _update_ambient_emitters()

    ambience_timer -= delta
    if ambience_timer <= 0.0:
        ambience_timer = rng.randf_range(5.0, 11.0)
        _play_random_city_sound()

func _ensure_audio_buses() -> void:
    _ensure_bus("Music")
    _ensure_bus("Environment")

func _ensure_bus(bus_name: String) -> void:
    if AudioServer.get_bus_index(bus_name) >= 0:
        return
    AudioServer.add_bus()
    AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

func _discover_music() -> void:
    var directory := DirAccess.open("res://assets/audio/music")
    if directory == null:
        return
    directory.list_dir_begin()
    var filename := directory.get_next()
    while filename != "":
        if not directory.current_is_dir() and _is_audio(filename):
            var path := "res://assets/audio/music/" + filename
            music_cache[filename.get_basename().to_lower()] = path
        filename = directory.get_next()
    directory.list_dir_end()

func _discover_ambient_audio() -> void:
    var directory := DirAccess.open("res://assets/audio/sfx")
    if directory == null:
        return
    directory.list_dir_begin()
    var filename := directory.get_next()
    while filename != "":
        if not directory.current_is_dir() and _is_audio(filename):
            var key := filename.get_basename().to_lower()
            ambient_cache[key] = "res://assets/audio/sfx/" + filename
        filename = directory.get_next()
    directory.list_dir_end()

func _is_audio(filename: String) -> bool:
    var lower := filename.to_lower()
    for extension in AUDIO_EXTENSIONS:
        if lower.ends_with(extension):
            return true
    return false

func _create_city_ambient_emitters() -> void:
    var sources := [
        {"name": "DowntownTraffic", "position": Vector3(0, 1.5, -12), "key": "traffic"},
        {"name": "CollegeAmbience", "position": Vector3(-58, 1.5, -42), "key": "college_ambient"},
        {"name": "SquareAmbience", "position": Vector3(0, 1.5, 0), "key": "square_ambient"},
        {"name": "MilitaryAmbience", "position": Vector3(55, 1.5, -48), "key": "military_ambient"},
        {"name": "HQAmbience", "position": Vector3(0, 1.5, 42), "key": "hq_ambient"}
    ]
    for source in sources:
        var path := _find_ambient_path(String(source.key))
        if path == "":
            continue
        var stream := load(path) as AudioStream
        if stream == null:
            continue
        var emitter := AudioStreamPlayer3D.new()
        emitter.name = String(source.name)
        emitter.position = source.position
        emitter.stream = stream
        emitter.bus = "Environment"
        emitter.volume_db = -10.0
        emitter.unit_size = 12.0
        emitter.max_distance = 55.0
        emitter.autoplay = true
        add_child(emitter)
        ambience_emitters.append(emitter)

func _find_ambient_path(key: String) -> String:
    if ambient_cache.has(key):
        return String(ambient_cache[key])
    for candidate in ambient_cache.keys():
        if String(candidate).contains(key):
            return String(ambient_cache[candidate])
    return ""

func _update_ambient_emitters() -> void:
    var db := -80.0 if area_sound_volume <= 0.001 else linear_to_db(area_sound_volume) - 2.0
    for emitter in ambience_emitters:
        if is_instance_valid(emitter):
            emitter.volume_db = db

func _play_random_city_sound() -> void:
    if player == null or ambient_cache.is_empty():
        return
    var candidates: Array[String] = []
    for key in ambient_cache.keys():
        var name := String(key)
        if name.contains("car") or name.contains("traffic") or name.contains("city") or name.contains("horn") or name.contains("crowd"):
            candidates.append(name)
    if candidates.is_empty():
        return
    var key := candidates[rng.randi_range(0, candidates.size() - 1)]
    var stream := load(String(ambient_cache[key])) as AudioStream
    if stream == null:
        return
    var emitter := AudioStreamPlayer3D.new()
    emitter.name = "TransientCitySound"
    var angle := rng.randf_range(0.0, TAU)
    var distance := rng.randf_range(10.0, 30.0)
    emitter.global_position = player.global_position + Vector3(cos(angle) * distance, rng.randf_range(0.5, 2.0), sin(angle) * distance)
    emitter.stream = stream
    emitter.bus = "Environment"
    emitter.volume_db = linear_to_db(clamp(area_sound_volume * rng.randf_range(0.18, 0.42), 0.001, 1.0))
    emitter.unit_size = 8.0
    emitter.max_distance = 42.0
    emitter.finished.connect(emitter.queue_free)
    add_child(emitter)
    emitter.play()

func _play_opening_music() -> void:
    var path := _find_music("opening")
    if path == "":
        path = _find_music("theme")
    if path == "":
        path = _music_for_area("downtown")
    if path == "":
        return
    _play_music_path(path, music_player, -8.0)

func _update_area_music(position: Vector3) -> void:
    var next_area := _get_area_for_position(position)
    if next_area == current_area:
        return
    current_area = next_area
    var path := _music_for_area(current_area)
    if path == "":
        return
    _crossfade_to(path)

func _get_area_for_position(position: Vector3) -> String:
    var best_area := "downtown"
    var best_distance := INF
    for zone in AREA_ZONES:
        var distance := Vector2(position.x - zone.center.x, position.z - zone.center.z).length()
        if distance <= float(zone.radius) and distance < best_distance:
            best_distance = distance
            best_area = String(zone.id)
    return best_area

func _music_for_area(area_id: String) -> String:
    var direct := _find_music(area_id)
    if direct != "":
        return direct
    if music_cache.is_empty():
        return ""
    var keys := music_cache.keys()
    keys.sort()
    var index := absi(area_id.hash()) % keys.size()
    return String(music_cache[keys[index]])

func _find_music(key: String) -> String:
    if music_cache.has(key):
        return String(music_cache[key])
    for candidate in music_cache.keys():
        if String(candidate).contains(key.to_lower()):
            return String(music_cache[candidate])
    return ""

func _play_music_path(path: String, target: AudioStreamPlayer, base_db: float) -> void:
    var stream := load(path) as AudioStream
    if stream == null:
        return
    target.stream = stream
    target.volume_db = base_db + (linear_to_db(music_volume) if music_volume > 0.001 else -80.0)
    target.play()

func _crossfade_to(path: String) -> void:
    var stream := load(path) as AudioStream
    if stream == null:
        return
    var old_player := area_player
    var new_player := music_player if old_player == area_player else area_player
    new_player.stream = stream
    new_player.volume_db = -80.0
    new_player.play()
    var target_db := -10.0 + (linear_to_db(music_volume) if music_volume > 0.001 else -80.0)
    var fade_in := create_tween()
    fade_in.tween_property(new_player, "volume_db", target_db, MUSIC_FADE_SECONDS)
    var fade_out := create_tween()
    fade_out.tween_property(old_player, "volume_db", -80.0, MUSIC_FADE_SECONDS)
    fade_out.tween_callback(old_player.stop)

func _on_music_finished(target: AudioStreamPlayer) -> void:
    if target.stream == null:
        return
    target.play()

func set_music_volume(linear_volume: float) -> void:
    music_volume = clamp(linear_volume, 0.0, 1.0)
    var music_db := -80.0 if music_volume <= 0.001 else linear_to_db(music_volume)
    if music_player != null:
        music_player.volume_db = -8.0 + music_db
    if area_player != null:
        area_player.volume_db = -10.0 + music_db

func set_area_sound_volume(linear_volume: float) -> void:
    area_sound_volume = clamp(linear_volume, 0.0, 1.0)
    var environment_bus := AudioServer.get_bus_index("Environment")
    if environment_bus >= 0:
        AudioServer.set_bus_volume_db(environment_bus, -80.0 if area_sound_volume <= 0.001 else linear_to_db(area_sound_volume))
    _update_ambient_emitters()

func get_current_area() -> String:
    return current_area
