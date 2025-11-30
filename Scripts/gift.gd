extends Node2D

@export var fall_duration: float = 0.8
@export var final_scale: float = 0.4
@export var miss_delay: float = 0.5

@onready var audio_snow_landing: AudioStreamPlayer2D = $audio_snowLanding
#@onready var audio_falling: AudioStreamPlayer2D = $audi_falling

@export var house_group: StringName = &"house"

func _ready() -> void:

	# Animate scaling down over fall_duration
	var start_scale := scale
	var target_scale := start_scale * final_scale

	var tween := create_tween()
	tween.tween_property(self, "scale", target_scale, fall_duration) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)

	await tween.finished
	await _resolve_landing()

func _resolve_landing() -> void:
	var house := _find_house_under()
	if house and house.has_method("receive_gift"):
		house.receive_gift()
		queue_free()
		return

	# Missed house
	audio_snow_landing.play()

	await get_tree().create_timer(miss_delay).timeout
	queue_free()


func _find_house_under() -> Node:
	var detector := $Detector as Area2D
	if detector == null:
		return null

	for body in detector.get_overlapping_bodies():
		if body.is_in_group(house_group):
			return body

	return null
