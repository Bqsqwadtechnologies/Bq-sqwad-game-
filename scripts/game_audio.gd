extends Node
class_name BQGameAudio

## Dynamic Landly City audio layer.
## Music is area-aware, while ambient emitters are positional 3D sounds.
## Audio assets are optional so the game remains bootable before the final sound pack is added.

const AREA_ZONES := [
    {"id": "downtown", "center": Vector3(0, 0, 0), "radius": 42.0, "music": "downtown"},
    {"id": "college", "center": Vector3(-58, 0, -42), "radius": 28.0, "music": "college"},
    {"id": "training", "center": Vector3(-38, 0, 38), "radius": 28.0, "music": "training"},
    {"id": "mission", "center": Vector3(38, 0, 38), "radius": 28.0, "music": "mission"},
    {"id": "military", "center": Vector3(55, 0, -48), "radius": 30.0, "music": "military"},
    {"id": "hq", "center": Vector3(0, 0, 42), "radius": 24.0, "music": "hq"}
]

const AUDIO_EXTENSIONS := [".ogg", ".wav", ".mp3"]

var music_player: AudioStreamPlayer
var area_player: AudioStreamPlayer
var player: Node3D
var current_area := "downtown"
var music_volume := 0.8
var area_sound_volume := 0.65
var music_cache: Dictionary = {}
var ambient_cache: Dictionary = {}
var ambience_emitters: Array[AudioStreamPlayer3D] = []
var ambience_timer := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    music_player = AudioStreamPlayer.new()
    music_player.name = "MusicPlayer"
    music_player.bus = "Master"
    add_child(music_player)

    area_player = AudioStreamPlayer.new()
    area_player.name = "AreaMusicPlayer"
    area_player.bus = "Master"
    add_child(area_player)

    _discover_music()
    _discover_ambient_audio()
    _create_city_ambient_emitters()
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
    # Named emitters make the final sound pack easy to swap in without code changes.
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
        emitter.bus = "Master"
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
    for emitter in ambience_emitters:
        emitter.volume_db = linear_to_db(clamp(area_sound_volume * 0.65, 0.001, 1.0))

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
    emitter.bus = "Master"
    emitter.volume_db = linear_to_db(clamp(area_sound_volume * rng.randf_range(0.18, 0.42), 0.001, 1.0))
    emitter.unit_size = 8.0
    emitter.max_distance = 42.0
    emitter.finished.connect(emitter.queue_free)
    add_child(emitter)
    emitter.play()

func _play_opening_music() -> void:
    var opening_path := _find_music("opening")
    if opening_path == "":
        opening_path = _find_music("theme")
    if opening_path == "":
        return
    _play_music_path(opening_path, music_player, -8.0)

func _update_area_music(position: Vector3) -> void:
    var next_area := "downtown"
    var best_distance := INF
    var best_music := "downtown"
    for zone in AREA_ZONES:
        var distance := Vector2(position.x - zone.center.x, position.z - zone.center.z).length()
        if distance <= float(zone.radius) and distance < best_distance:
            best_distance = distance
            next_area = String(zone.id)
            best_music = String(zone.music)

    if next_area == current_area:
        return
    current_area = next_area
    var path := _find_music(best_music)
    if path == "":
        return
    _play_music_path(path, area_player, -10.0)

func _find_music(key: String) -> String:
    if music_cache.has(key):
        return String(music_cache[key])
    for candidate in music_cache.keys():
        if String(candidate).contains(key):
            return String(music_cache[candidate])
    return ""

func _play_music_path(path: String, target: AudioStreamPlayer, base_db: float) -> void:
    var stream := load(path) as AudioStream
    if stream == null:
        return
    target.stream = stream
    target.volume_db = base_db + linear_to_db(clamp(music_volume, 0.001, 1.0))
    target.play()

func set_music_volume(linear_volume: float) -> void:
    music_volume = clamp(linear_volume, 0.0, 1.0)
    if music_player != null:
        music_player.volume_db = -80.0 if music_volume <= 0.001 else -8.0 + linear_to_db(music_volume)
    if area_player != null:
        area_player.volume_db = -80.0 if music_volume <= 0.001 else -10.0 + linear_to_db(music_volume)

func set_area_sound_volume(linear_volume: float) -> void:
    area_sound_volume = clamp(linear_volume, 0.0, 1.0)
    _update_ambient_emitters()

func get_current_area() -> String:
    return current_area
