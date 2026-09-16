extends Node
class_name BQGameAudio

## Finds optional music already placed under assets/audio/music.
## No audio file is required for the game to boot.

var music_player: AudioStreamPlayer
var music_files: Array[String] = []

func _ready() -> void:
    music_player = AudioStreamPlayer.new()
    music_player.name = "MusicPlayer"
    music_player.bus = "Master"
    add_child(music_player)
    _discover_music()
    _play_opening_music()

func _discover_music() -> void:
    var directory := DirAccess.open("res://assets/audio/music")
    if directory == null:
        return
    directory.list_dir_begin()
    var filename := directory.get_next()
    while filename != "":
        if not directory.current_is_dir():
            var lower := filename.to_lower()
            if lower.ends_with(".ogg") or lower.ends_with(".wav") or lower.ends_with(".mp3"):
                music_files.append("res://assets/audio/music/" + filename)
        filename = directory.get_next()
    directory.list_dir_end()
    music_files.sort()

func _play_opening_music() -> void:
    if music_files.is_empty():
        return
    var opening_path := ""
    for path in music_files:
        if path.to_lower().contains("opening") or path.to_lower().contains("theme"):
            opening_path = path
            break
    if opening_path == "":
        opening_path = music_files[0]

    var stream := load(opening_path) as AudioStream
    if stream == null:
        return
    music_player.stream = stream
    music_player.volume_db = -8.0
    music_player.play()

func set_music_volume(linear_volume: float) -> void:
    if music_player == null:
        return
    if linear_volume <= 0.001:
        music_player.volume_db = -80.0
    else:
        music_player.volume_db = linear_to_db(clamp(linear_volume, 0.001, 1.0))
