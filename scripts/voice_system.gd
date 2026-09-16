extends Node
class_name BQVoiceSystem

signal listening_started
signal listening_stopped
signal player_voice_ready(character_id: String, audio: AudioStream)

# Voice architecture:
# 1) Character voice files are optional and live under assets/audio/voices/<character>/.
# 2) If a player chooses "Speak for Character", the microphone recording is used
#    for that character's dialogue instead of inventing a voice.
# 3) Character-owned voice assets can be added later without changing gameplay code.
# 4) This system deliberately does not transmit microphone audio anywhere.

var active_character_id := "ziking"
var player_voice_mode := true
var recording := false
var _recording: AudioStreamWAV
var _capture_bus_index := -1

func set_active_character(character_id: String) -> void:
    active_character_id = character_id

func set_player_voice_mode(enabled: bool) -> void:
    player_voice_mode = enabled

func start_microphone() -> bool:
    if recording:
        return true
    if not AudioServer.has_method("get_input_device_list"):
        # Android microphone availability is handled by the project/platform;
        # keep the gameplay system safe when input capture is unavailable.
        return false
    recording = true
    listening_started.emit()
    return true

func stop_microphone() -> void:
    if not recording:
        return
    recording = false
    listening_stopped.emit()

func set_recorded_voice(audio: AudioStream) -> void:
    if audio == null:
        return
    player_voice_ready.emit(active_character_id, audio)

func get_character_voice_path(character_id: String) -> String:
    return "res://assets/audio/voices/%s/voice.ogg" % character_id

func is_player_voice_mode() -> bool:
    return player_voice_mode
