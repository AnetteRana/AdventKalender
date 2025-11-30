extends Node2D

signal _on_house_filled

@export var good_sounds: Array[AudioStream] = []
@export var bad_sounds: Array[AudioStream] = []
@onready var audio_player_comp: AudioStreamPlayer2D = $AudioPlayerComp

var has_gift: bool = false

func receive_gift() -> void:
	if has_gift == true:
		audio_player_comp.stream = bad_sounds.pick_random()
		audio_player_comp.play()
	else:
		has_gift = true
		emit_signal("_on_house_filled") #to gameManager
		
		# play sound
		audio_player_comp.stream = good_sounds.pick_random()
		audio_player_comp.play()
