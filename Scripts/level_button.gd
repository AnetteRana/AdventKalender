extends Control

@export var level_path: String
@export var unlock_date: String = "2025-12-01"  # format YYYY-MM-DD
@export var audio_clicked: AudioStream = preload("res://Assets/Audio/3Bells.wav")
@onready var button: Button = $Button

func _ready():
	var now = Time.get_datetime_dict_from_system()
	var todays_date = "%04d-%02d-%02d" % [now.year, now.month, now.day]

	if todays_date < unlock_date: # Locked
		button.disabled = true
		button.text = "Locked until %s" % [unlock_date]
	else: # Unlocked
		button.disabled = false

	button.pressed.connect(_on_pressed)

func _on_pressed(): #only when enabled
	if not button.disabled and level_path != "":
		_playAudio()
		get_tree().change_scene_to_file(level_path)

func _playAudio(): #TODO: make an audio manager instead
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = audio_clicked
	player.play()
