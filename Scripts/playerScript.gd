extends Node2D

signal _on_gift_thrown
@export var gift_scene: PackedScene
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _physics_process(_delta: float):
	if Input.is_action_just_pressed("DropGift"):
		spawn_gift()
		audio_stream_player_2d.play()
		
func spawn_gift():
	if gift_scene == null:
		return
		
	var gift = gift_scene.instantiate()
	emit_signal("_on_gift_thrown") #to gameManager
	gift.position = position
	get_parent().add_child(gift)
